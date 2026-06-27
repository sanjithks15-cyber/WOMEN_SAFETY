import prisma from "../config/db";
import { SOSAlertRepository } from "../repositories/sos.repository";
import { BadRequestException } from "../exceptions/http.exception";
import { SocketService } from "../config/socket";
import logger from "../config/logger";

export class SOSAlertService {
  private sosRepo = new SOSAlertRepository();

  async triggerSOS(userId: string, latitude: number, longitude: number) {
    const activeSOS = await this.sosRepo.findActiveByUserId(userId);
    if (activeSOS) {
      // Hackathon bypass: Auto-resolve any stuck active SOS alerts instead of failing
      await this.resolveSOS(userId, activeSOS.id);
    }

    const alert = await prisma.$transaction(async (tx) => {
      // 1. Create SOS Alert
      const alert = await tx.sOSAlert.create({
        data: {
          userId,
          status: "ACTIVE",
          latitude,
          longitude,
        },
      });

      // 2. If user has active journey, transition status to SOS
      const activeJourney = await tx.journey.findFirst({
        where: { userId, status: "ACTIVE", deletedAt: null },
      });
      if (activeJourney) {
        await tx.journey.update({
          where: { id: activeJourney.id },
          data: { status: "SOS" },
        });
      }

      // 3. Fetch guardians to alert them
      const guardians = await tx.guardian.findMany({
        where: { userId, deletedAt: null },
      });

      // 4. Create in-app notifications
      if (guardians.length > 0) {
        const notificationsData = guardians.map((g) => ({
          userId,
          title: "SOS Distress Alert",
          message: `Emergency contact needs help! Location: ${latitude}, ${longitude}`,
          type: "sos",
          isRead: false,
        }));
        await tx.notification.createMany({
          data: notificationsData,
        });
      }

      return alert;
    });

    // Emit real-time SOS socket alert
    try {
      SocketService.sendSOSAlert(userId, alert);
    } catch (error) {
      logger.error(`Failed to emit SOS socket alert: ${error}`);
    }

    return alert;
  }

  async resolveSOS(userId: string, id: string) {
    const sos = await this.sosRepo.findById(id);
    if (!sos || sos.userId !== userId) {
      throw new BadRequestException("SOS alert not found");
    }

    const resolved = await prisma.$transaction(async (tx) => {
      const resolved = await tx.sOSAlert.update({
        where: { id },
        data: { status: "RESOLVED", resolvedAt: new Date() },
      });

      const activeJourney = await tx.journey.findFirst({
        where: { userId, status: "SOS", deletedAt: null },
      });
      if (activeJourney) {
        await tx.journey.update({
          where: { id: activeJourney.id },
          data: { status: "COMPLETED" },
        });
      }

      return resolved;
    });

    // Emit real-time SOS resolution status update
    try {
      SocketService.sendSOSAlert(userId, resolved);
    } catch (error) {
      logger.error(`Failed to emit SOS resolved socket alert: ${error}`);
    }

    return resolved;
  }
}

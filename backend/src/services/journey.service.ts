import { JourneyRepository } from "../repositories/journey.repository";
import { BadRequestException, NotFoundException } from "../exceptions/http.exception";
import { SocketService } from "../config/socket";
import logger from "../config/logger";

export class JourneyService {
  private journeyRepo = new JourneyRepository();

  async planJourney(
    userId: string,
    from: string,
    to: string,
    duration: string,
    routeType: string
  ) {
    const active = await this.journeyRepo.findActiveByUserId(userId);
    if (active) {
      throw new BadRequestException("You already have an active journey. Complete or cancel it first.");
    }

    return this.journeyRepo.create({
      userId,
      from,
      to,
      duration,
      routeType,
      progress: 0.0,
      status: "ACTIVE",
    });
  }

  async updateProgress(
    userId: string,
    id: string,
    progress: number,
    status?: string,
    latitude?: number,
    longitude?: number
  ) {
    const journey = await this.journeyRepo.findById(id);
    if (!journey || journey.userId !== userId) {
      throw new NotFoundException("Journey not found");
    }

    const updated = await this.journeyRepo.update(id, {
      progress,
      status: (status as any) || journey.status,
    });

    if (latitude !== undefined && longitude !== undefined) {
      try {
        SocketService.sendLocationUpdate(id, {
          latitude,
          longitude,
          progress: updated.progress,
        });
      } catch (error) {
        logger.error(`Failed to emit location update for journey ${id}: ${error}`);
      }
    }

    return updated;
  }

  async getHistory(userId: string, page: number, limit: number) {
    return this.journeyRepo.findByUserId(userId, page, limit);
  }
}

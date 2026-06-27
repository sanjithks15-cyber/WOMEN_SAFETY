import prisma from "../config/db";
import { SOSAlert, Prisma } from "@prisma/client";

export class SOSAlertRepository {
  async create(data: Prisma.SOSAlertUncheckedCreateInput): Promise<SOSAlert> {
    return prisma.sOSAlert.create({ data });
  }

  async findById(id: string): Promise<SOSAlert | null> {
    return prisma.sOSAlert.findUnique({
      where: { id },
    });
  }

  async findActiveByUserId(userId: string): Promise<SOSAlert | null> {
    return prisma.sOSAlert.findFirst({
      where: { userId, status: "ACTIVE" },
    });
  }

  async update(id: string, data: Prisma.SOSAlertUpdateInput): Promise<SOSAlert> {
    return prisma.sOSAlert.update({
      where: { id },
      data,
    });
  }
}

import prisma from "../config/db";
import { Journey, Prisma } from "@prisma/client";

export class JourneyRepository {
  async create(data: Prisma.JourneyUncheckedCreateInput): Promise<Journey> {
    return prisma.journey.create({ data });
  }

  async findById(id: string): Promise<Journey | null> {
    return prisma.journey.findFirst({
      where: { id, deletedAt: null },
    });
  }

  async findActiveByUserId(userId: string): Promise<Journey | null> {
    return prisma.journey.findFirst({
      where: { userId, status: "ACTIVE", deletedAt: null },
    });
  }

  async findByUserId(
    userId: string,
    page: number,
    limit: number
  ): Promise<{ data: Journey[]; total: number }> {
    const skip = (page - 1) * limit;
    const [data, total] = await Promise.all([
      prisma.journey.findMany({
        where: { userId, deletedAt: null },
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
      }),
      prisma.journey.count({
        where: { userId, deletedAt: null },
      }),
    ]);
    return { data, total };
  }

  async update(id: string, data: Prisma.JourneyUpdateInput): Promise<Journey> {
    return prisma.journey.update({
      where: { id },
      data,
    });
  }

  async softDelete(id: string): Promise<Journey> {
    return prisma.journey.update({
      where: { id },
      data: { deletedAt: new Date() },
    });
  }
}

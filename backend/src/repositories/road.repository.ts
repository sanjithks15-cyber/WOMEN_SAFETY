import prisma from "../config/db";
import { RoadReport, Prisma } from "@prisma/client";

export class RoadReportRepository {
  async create(data: Prisma.RoadReportCreateInput): Promise<RoadReport> {
    return prisma.roadReport.create({ data });
  }

  async findAll(
    page: number,
    limit: number
  ): Promise<{ data: RoadReport[]; total: number }> {
    const skip = (page - 1) * limit;
    const [data, total] = await Promise.all([
      prisma.roadReport.findMany({
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
      }),
      prisma.roadReport.count(),
    ]);
    return { data, total };
  }

  async findLastReportByUserId(userId: string): Promise<RoadReport | null> {
    return prisma.roadReport.findFirst({
      where: { userId },
      orderBy: { createdAt: "desc" },
    });
  }
}


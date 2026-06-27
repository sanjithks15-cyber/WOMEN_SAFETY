import prisma from "../config/db";
import { CrimeZone, Prisma } from "@prisma/client";

export class CrimeZoneRepository {
  async create(data: Prisma.CrimeZoneCreateInput): Promise<CrimeZone> {
    return prisma.crimeZone.create({ data });
  }

  async findById(id: string): Promise<CrimeZone | null> {
    return prisma.crimeZone.findUnique({
      where: { id },
    });
  }

  async findAll(
    riskLevel?: string,
    page?: number,
    limit?: number
  ): Promise<{ data: CrimeZone[]; total: number }> {
    const where: Prisma.CrimeZoneWhereInput = riskLevel && riskLevel !== "all"
      ? { riskLevel }
      : {};

    if (page && limit) {
      const skip = (page - 1) * limit;
      const [data, total] = await Promise.all([
        prisma.crimeZone.findMany({
          where,
          skip,
          take: limit,
          orderBy: { reportsCount: "desc" },
        }),
        prisma.crimeZone.count({ where }),
      ]);
      return { data, total };
    }

    const data = await prisma.crimeZone.findMany({ where, orderBy: { reportsCount: "desc" } });
    return { data, total: data.length };
  }

  async update(id: string, data: Prisma.CrimeZoneUpdateInput): Promise<CrimeZone> {
    return prisma.crimeZone.update({
      where: { id },
      data,
    });
  }

  async delete(id: string): Promise<CrimeZone> {
    return prisma.crimeZone.delete({
      where: { id },
    });
  }
}

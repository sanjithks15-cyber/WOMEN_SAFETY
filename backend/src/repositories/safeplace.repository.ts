import prisma from "../config/db";
import { SafePlace, Prisma } from "@prisma/client";

export class SafePlaceRepository {
  async create(data: Prisma.SafePlaceCreateInput): Promise<SafePlace> {
    return prisma.safePlace.create({ data });
  }

  async findById(id: string): Promise<SafePlace | null> {
    return prisma.safePlace.findUnique({
      where: { id },
    });
  }

  async findAll(
    category?: string,
    page?: number,
    limit?: number
  ): Promise<{ data: SafePlace[]; total: number }> {
    const where: Prisma.SafePlaceWhereInput = category && category !== "all"
      ? { category }
      : {};

    if (page && limit) {
      const skip = (page - 1) * limit;
      const [data, total] = await Promise.all([
        prisma.safePlace.findMany({
          where,
          skip,
          take: limit,
          orderBy: { name: "asc" },
        }),
        prisma.safePlace.count({ where }),
      ]);
      return { data, total };
    }

    const data = await prisma.safePlace.findMany({ where, orderBy: { name: "asc" } });
    return { data, total: data.length };
  }

  async update(id: string, data: Prisma.SafePlaceUpdateInput): Promise<SafePlace> {
    return prisma.safePlace.update({
      where: { id },
      data,
    });
  }

  async delete(id: string): Promise<SafePlace> {
    return prisma.safePlace.delete({
      where: { id },
    });
  }
}

import prisma from "../config/db";
import { Guardian, Prisma } from "@prisma/client";

export class GuardianRepository {
  async create(data: Prisma.GuardianUncheckedCreateInput): Promise<Guardian> {
    return prisma.guardian.create({ data });
  }

  async findById(id: string): Promise<Guardian | null> {
    return prisma.guardian.findFirst({
      where: { id, deletedAt: null },
    });
  }

  async findByUserId(userId: string): Promise<Guardian[]> {
    return prisma.guardian.findMany({
      where: { userId, deletedAt: null },
    });
  }

  async update(id: string, data: Prisma.GuardianUpdateInput): Promise<Guardian> {
    return prisma.guardian.update({
      where: { id },
      data,
    });
  }

  async softDelete(id: string): Promise<Guardian> {
    return prisma.guardian.update({
      where: { id },
      data: { deletedAt: new Date() },
    });
  }
}

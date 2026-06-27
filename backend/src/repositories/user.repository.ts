import prisma from "../config/db";
import { User, Prisma } from "@prisma/client";

export class UserRepository {
  async create(data: Prisma.UserCreateInput): Promise<User> {
    return prisma.user.create({ data });
  }

  async findById(id: string): Promise<User | null> {
    return prisma.user.findFirst({
      where: { id, deletedAt: null },
    });
  }

  async findByPhone(phone: string): Promise<User | null> {
    return prisma.user.findFirst({
      where: { phone, deletedAt: null },
    });
  }

  async update(id: string, data: Prisma.UserUpdateInput): Promise<User> {
    return prisma.user.update({
      where: { id },
      data,
    });
  }

  async softDelete(id: string): Promise<User> {
    return prisma.user.update({
      where: { id },
      data: { deletedAt: new Date() },
    });
  }

  async findAll(page: number, limit: number): Promise<{ data: User[]; total: number }> {
    const skip = (page - 1) * limit;
    const [data, total] = await Promise.all([
      prisma.user.findMany({
        where: { deletedAt: null },
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
      }),
      prisma.user.count({
        where: { deletedAt: null },
      }),
    ]);
    return { data, total };
  }
}

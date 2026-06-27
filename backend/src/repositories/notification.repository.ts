import prisma from "../config/db";
import { Notification, Prisma } from "@prisma/client";

export class NotificationRepository {
  async create(data: Prisma.NotificationUncheckedCreateInput): Promise<Notification> {
    return prisma.notification.create({ data });
  }

  async findByUserId(
    userId: string,
    page: number,
    limit: number
  ): Promise<{ data: Notification[]; total: number }> {
    const skip = (page - 1) * limit;
    const [data, total] = await Promise.all([
      prisma.notification.findMany({
        where: { userId },
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
      }),
      prisma.notification.count({ where: { userId } }),
    ]);
    return { data, total };
  }

  async markAllAsRead(userId: string): Promise<Prisma.BatchPayload> {
    return prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true },
    });
  }

  async update(id: string, data: Prisma.NotificationUpdateInput): Promise<Notification> {
    return prisma.notification.update({
      where: { id },
      data,
    });
  }
}

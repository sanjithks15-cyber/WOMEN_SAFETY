import { NotificationRepository } from "../repositories/notification.repository";

export class NotificationService {
  private notificationRepo = new NotificationRepository();

  async createNotification(userId: string, title: string, message: string, type: string) {
    return this.notificationRepo.create({
      userId,
      title,
      message,
      type,
      isRead: false,
    });
  }

  async getNotifications(userId: string, page: number, limit: number) {
    return this.notificationRepo.findByUserId(userId, page, limit);
  }

  async markAllRead(userId: string) {
    return this.notificationRepo.markAllAsRead(userId);
  }

  async toggleRead(userId: string, id: string, isRead: boolean) {
    return this.notificationRepo.update(id, { isRead });
  }
}

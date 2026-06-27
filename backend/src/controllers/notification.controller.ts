import { NextFunction, Response } from "express";
import { NotificationService } from "../services/notification.service";
import { AuthenticatedRequest } from "../middleware/authenticated-request.interface";

export class NotificationController {
  private notificationService = new NotificationService();

  public getNotifications = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user!.id;
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const result = await this.notificationService.getNotifications(userId, page, limit);
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  };

  public markAllRead = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user!.id;
      await this.notificationService.markAllRead(userId);
      res.status(200).json({ message: "All notifications marked as read" });
    } catch (error) {
      next(error);
    }
  };

  public toggleRead = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user!.id;
      const { id } = req.params;
      const { isRead } = req.body;
      const notification = await this.notificationService.toggleRead(userId, id, isRead === true || isRead === "true");
      res.status(200).json(notification);
    } catch (error) {
      next(error);
    }
  };
}

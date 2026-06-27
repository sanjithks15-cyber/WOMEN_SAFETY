import { NextFunction, Response } from "express";
import { JourneyService } from "../services/journey.service";
import { AuthenticatedRequest } from "../middleware/authenticated-request.interface";

export class JourneyController {
  private journeyService = new JourneyService();

  public planJourney = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user!.id;
      const { from, to, duration, routeType } = req.body;
      const journey = await this.journeyService.planJourney(userId, from, to, duration, routeType);
      res.status(201).json(journey);
    } catch (error) {
      next(error);
    }
  };

  public updateProgress = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user!.id;
      const { id } = req.params;
      const { progress, status, latitude, longitude } = req.body;
      const journey = await this.journeyService.updateProgress(
        userId,
        id,
        progress,
        status,
        latitude !== undefined ? parseFloat(latitude) : undefined,
        longitude !== undefined ? parseFloat(longitude) : undefined
      );
      res.status(200).json(journey);
    } catch (error) {
      next(error);
    }
  };

  public getHistory = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user!.id;
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const history = await this.journeyService.getHistory(userId, page, limit);
      res.status(200).json(history);
    } catch (error) {
      next(error);
    }
  };
}

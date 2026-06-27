import { NextFunction, Response } from "express";
import { SOSAlertService } from "../services/sos.service";
import { AuthenticatedRequest } from "../middleware/authenticated-request.interface";

export class SOSAlertController {
  private sosService = new SOSAlertService();

  public triggerSOS = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user!.id;
      const { latitude, longitude } = req.body;
      const alert = await this.sosService.triggerSOS(userId, parseFloat(latitude), parseFloat(longitude));
      res.status(201).json(alert);
    } catch (error) {
      next(error);
    }
  };

  public resolveSOS = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user!.id;
      const { id } = req.params;
      const resolved = await this.sosService.resolveSOS(userId, id);
      res.status(200).json(resolved);
    } catch (error) {
      next(error);
    }
  };
}

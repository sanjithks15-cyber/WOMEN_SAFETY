import { NextFunction, Response } from "express";
import { GuardianService } from "../services/guardian.service";
import { AuthenticatedRequest } from "../middleware/authenticated-request.interface";

export class GuardianController {
  private guardianService = new GuardianService();

  public addGuardian = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user!.id;
      const { name, relation, phone } = req.body;
      const guardian = await this.guardianService.addGuardian(userId, name, relation, phone);
      res.status(201).json(guardian);
    } catch (error) {
      next(error);
    }
  };

  public getGuardians = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user!.id;
      const guardians = await this.guardianService.getGuardians(userId);
      res.status(200).json(guardians);
    } catch (error) {
      next(error);
    }
  };

  public deleteGuardian = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user!.id;
      const { id } = req.params;
      await this.guardianService.deleteGuardian(userId, id);
      res.status(200).json({ message: "Guardian contact deleted successfully" });
    } catch (error) {
      next(error);
    }
  };
}

import { NextFunction, Response } from "express";
import { AuthService } from "../services/auth.service";
import { AuthenticatedRequest } from "../middleware/authenticated-request.interface";

export class AuthController {
  private authService = new AuthService();

  public register = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const { phone, name, pin, role } = req.body;
      const result = await this.authService.register(phone, name, pin, role);
      res.status(201).json(result);
    } catch (error) {
      next(error);
    }
  };

  public login = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const { phone, pin } = req.body;
      const result = await this.authService.login(phone, pin);
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  };

  public getProfile = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user!.id;
      const result = await this.authService.getProfile(userId);
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  };
}

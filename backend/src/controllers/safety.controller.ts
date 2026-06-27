import { NextFunction, Response } from "express";
import { SafetyService } from "../services/safety.service";
import { AuthenticatedRequest } from "../middleware/authenticated-request.interface";

export class SafetyController {
  private safetyService = new SafetyService();

  // --- Crime Zones ---
  public addCrimeZone = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const { name, latitude, longitude, riskLevel, description, lastIncident } = req.body;
      const zone = await this.safetyService.addCrimeZone(
        name,
        parseFloat(latitude),
        parseFloat(longitude),
        riskLevel,
        description,
        lastIncident
      );
      res.status(201).json(zone);
    } catch (error) {
      next(error);
    }
  };

  public getCrimeZones = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const riskLevel = req.query.riskLevel as string;
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const result = await this.safetyService.getCrimeZones(riskLevel, page, limit);
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  };

  public updateCrimeZone = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const zone = await this.safetyService.updateCrimeZone(id, req.body);
      res.status(200).json(zone);
    } catch (error) {
      next(error);
    }
  };

  // --- Safe Places ---
  public addSafePlace = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const { name, category, latitude, longitude, address, phone, is24x7 } = req.body;
      const place = await this.safetyService.addSafePlace(
        name,
        category,
        parseFloat(latitude),
        parseFloat(longitude),
        address,
        phone,
        is24x7 === true || is24x7 === "true"
      );
      res.status(201).json(place);
    } catch (error) {
      next(error);
    }
  };

  public getSafePlaces = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const category = req.query.category as string;
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const result = await this.safetyService.getSafePlaces(category, page, limit);
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  };

  // --- Road Reports ---
  public createRoadReport = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user!.id;
      const { roadName, reporterName, rating, tags, comment } = req.body;
      const report = await this.safetyService.createRoadReport(
        userId,
        roadName,
        reporterName || "Anonymous",
        parseFloat(rating),
        tags || [],
        comment || ""
      );
      res.status(201).json(report);
    } catch (error) {
      next(error);
    }
  };

  public getRoadReports = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const reports = await this.safetyService.getRoadReports(page, limit);
      res.status(200).json(reports);
    } catch (error) {
      next(error);
    }
  };
}

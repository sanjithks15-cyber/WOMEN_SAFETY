import { CrimeZoneRepository } from "../repositories/crime.repository";
import { SafePlaceRepository } from "../repositories/safeplace.repository";
import { RoadReportRepository } from "../repositories/road.repository";
import { NotFoundException, TooManyRequestsException } from "../exceptions/http.exception";

export class SafetyService {
  private crimeRepo = new CrimeZoneRepository();
  private safePlaceRepo = new SafePlaceRepository();
  private roadReportRepo = new RoadReportRepository();

  // --- Crime Zones ---
  async addCrimeZone(name: string, latitude: number, longitude: number, riskLevel: string, description: string, lastIncident: string) {
    return this.crimeRepo.create({
      name,
      latitude,
      longitude,
      riskLevel,
      description,
      lastIncident,
    });
  }

  async getCrimeZones(riskLevel?: string, page?: number, limit?: number) {
    return this.crimeRepo.findAll(riskLevel, page, limit);
  }

  async updateCrimeZone(id: string, data: any) {
    const zone = await this.crimeRepo.findById(id);
    if (!zone) throw new NotFoundException("Crime zone not found");
    return this.crimeRepo.update(id, data);
  }

  // --- Safe Places ---
  async addSafePlace(name: string, category: string, latitude: number, longitude: number, address: string, phone: string, is24x7: boolean) {
    return this.safePlaceRepo.create({
      name,
      category,
      latitude,
      longitude,
      address,
      phone,
      is24x7,
    });
  }

  async getSafePlaces(category?: string, page?: number, limit?: number) {
    return this.safePlaceRepo.findAll(category, page, limit);
  }

  // --- Road Reports ---
  async createRoadReport(userId: string, roadName: string, reporterName: string, rating: number, tags: string[], comment: string) {
    const lastReport = await this.roadReportRepo.findLastReportByUserId(userId);
    if (lastReport) {
      const timeDiff = Date.now() - new Date(lastReport.createdAt).getTime();
      const limitMs = 60 * 1000; // 1 minute
      if (timeDiff < limitMs) {
        throw new TooManyRequestsException("You can only submit one road report per minute.");
      }
    }

    const report = await this.roadReportRepo.create({
      roadName,
      reporterName,
      rating,
      tags: tags.join(','),
      comment,
      user: userId ? { connect: { id: userId } } : undefined,
    });
    return { ...report, tags: report.tags ? report.tags.split(',') : [] };
  }

  async getRoadReports(page: number, limit: number) {
    const result = await this.roadReportRepo.findAll(page, limit);
    return {
      total: result.total,
      data: result.data.map(r => ({
        ...r,
        tags: r.tags ? r.tags.split(',') : [],
      })),
    };
  }
}

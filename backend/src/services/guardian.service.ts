import { GuardianRepository } from "../repositories/guardian.repository";
import { NotFoundException } from "../exceptions/http.exception";

export class GuardianService {
  private guardianRepo = new GuardianRepository();

  async addGuardian(userId: string, name: string, relation: string, phone: string) {
    return this.guardianRepo.create({
      userId,
      name,
      relation,
      phone,
    });
  }

  async getGuardians(userId: string) {
    return this.guardianRepo.findByUserId(userId);
  }

  async deleteGuardian(userId: string, id: string) {
    const guardian = await this.guardianRepo.findById(id);
    if (!guardian || guardian.userId !== userId) {
      throw new NotFoundException("Guardian contact not found");
    }
    return this.guardianRepo.softDelete(id);
  }
}

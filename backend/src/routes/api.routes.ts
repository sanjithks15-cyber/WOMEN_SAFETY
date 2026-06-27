import { Router } from "express";
import { AuthController } from "../controllers/auth.controller";
import { GuardianController } from "../controllers/guardian.controller";
import { JourneyController } from "../controllers/journey.controller";
import { SOSAlertController } from "../controllers/sos.controller";
import { SafetyController } from "../controllers/safety.controller";
import { NotificationController } from "../controllers/notification.controller";
import { authMiddleware } from "../middleware/auth.middleware";
import { requireRoles } from "../middleware/rbac.middleware";

const router = Router();

const authCtrl = new AuthController();
const guardianCtrl = new GuardianController();
const journeyCtrl = new JourneyController();
const sosCtrl = new SOSAlertController();
const safetyCtrl = new SafetyController();
const notificationCtrl = new NotificationController();

// --- Auth Routes ---
router.post("/auth/register", authCtrl.register);
router.post("/auth/login", authCtrl.login);
router.get("/auth/profile", authMiddleware as any, authCtrl.getProfile);

// --- Guardian Routes ---
router.post("/guardians", authMiddleware as any, guardianCtrl.addGuardian);
router.get("/guardians", authMiddleware as any, guardianCtrl.getGuardians);
router.delete("/guardians/:id", authMiddleware as any, guardianCtrl.deleteGuardian);

// --- Journey Routes ---
router.post("/journeys", authMiddleware as any, journeyCtrl.planJourney);
router.patch("/journeys/:id", authMiddleware as any, journeyCtrl.updateProgress);
router.get("/journeys/history", authMiddleware as any, journeyCtrl.getHistory);

// --- SOS Routes ---
router.post("/sos/trigger", authMiddleware as any, sosCtrl.triggerSOS);
router.patch("/sos/resolve/:id", authMiddleware as any, sosCtrl.resolveSOS);

// --- Safety - Crime Zones ---
router.post(
  "/safety/crime-zones",
  authMiddleware as any,
  requireRoles(["ADMIN"]),
  safetyCtrl.addCrimeZone
);
router.get("/safety/crime-zones", authMiddleware as any, safetyCtrl.getCrimeZones);
router.patch(
  "/safety/crime-zones/:id",
  authMiddleware as any,
  requireRoles(["ADMIN", "POLICE"]),
  safetyCtrl.updateCrimeZone
);

// --- Safety - Safe Places ---
router.post(
  "/safety/safe-places",
  authMiddleware as any,
  requireRoles(["ADMIN"]),
  safetyCtrl.addSafePlace
);
router.get("/safety/safe-places", authMiddleware as any, safetyCtrl.getSafePlaces);

// --- Safety - Road Reports ---
router.post("/safety/road-reports", authMiddleware as any, safetyCtrl.createRoadReport);
router.get("/safety/road-reports", authMiddleware as any, safetyCtrl.getRoadReports);

// --- Notifications ---
router.get("/notifications", authMiddleware as any, notificationCtrl.getNotifications);
router.post("/notifications/mark-read", authMiddleware as any, notificationCtrl.markAllRead);
router.patch("/notifications/:id", authMiddleware as any, notificationCtrl.toggleRead);

export default router;

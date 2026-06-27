import '../models/guardian_model.dart';
import '../models/crime_zone_model.dart';
import '../models/safe_place_model.dart';
import '../models/journey_model.dart';
import '../models/app_models.dart';

class MockData {
  static final List<Guardian> mockGuardians = [
    Guardian(id: 'g1', name: 'Aarav Sharma', relation: 'Father', phone: '+919876543210'),
    Guardian(id: 'g2', name: 'Neha Sharma', relation: 'Mother', phone: '+919876543211'),
    Guardian(id: 'g3', name: 'Rohan Gupta', relation: 'Friend', phone: '+919876543212'),
  ];

  static final List<CrimeZone> mockCrimeZones = [
    CrimeZone(
      id: 'cz1',
      name: 'Koramangala Outer Ring Rd',
      latitude: 12.9279,
      longitude: 77.6271,
      riskLevel: 'high',
      description: 'Recent chain snatching and isolated stretches at night.',
      reportsCount: 15,
      lastIncident: '2 hours ago',
    ),
    CrimeZone(
      id: 'cz2',
      name: 'Indiranagar 100 Feet Rd',
      latitude: 12.9719,
      longitude: 77.6412,
      riskLevel: 'medium',
      description: 'Crowded market area, pickpocketing and minor altercations.',
      reportsCount: 8,
      lastIncident: '1 day ago',
    ),
    CrimeZone(
      id: 'cz3',
      name: 'HSR Layout Sector 2',
      latitude: 12.9103,
      longitude: 77.6450,
      riskLevel: 'low',
      description: 'Generally safe, well-lit residential area with active patrolling.',
      reportsCount: 2,
      lastIncident: '5 days ago',
    ),
    CrimeZone(
      id: 'cz4',
      name: 'MG Road Junction',
      latitude: 12.9756,
      longitude: 77.6068,
      riskLevel: 'medium',
      description: 'Heavy traffic and crowded areas. Reported vehicle thefts.',
      reportsCount: 12,
      lastIncident: '12 hours ago',
    ),
  ];

  static final List<SafePlace> mockSafePlaces = [
    SafePlace(
      id: 'sp1',
      name: 'Koramangala Police Station',
      category: 'police',
      latitude: 12.9348,
      longitude: 77.6189,
      address: '80 Feet Rd, Koramangala 4th Block, Bengaluru',
      phone: '080-22942566',
      is24x7: true,
    ),
    SafePlace(
      id: 'sp2',
      name: 'St. John Hospital',
      category: 'hospital',
      latitude: 12.9339,
      longitude: 77.6244,
      address: 'Sarjapur Road, Koramangala, Bengaluru',
      phone: '080-22065000',
      is24x7: true,
    ),
    SafePlace(
      id: 'sp3',
      name: 'Indiranagar Metro Station',
      category: 'metro',
      latitude: 12.9783,
      longitude: 77.6386,
      address: 'CMH Road, Indiranagar, Bengaluru',
      phone: '080-25156666',
      is24x7: false,
    ),
    SafePlace(
      id: 'sp4',
      name: '24/7 Safeway Express',
      category: 'store',
      latitude: 12.9312,
      longitude: 77.6220,
      address: '5th Block, Koramangala, Bengaluru',
      phone: '+919988776655',
      is24x7: true,
    ),
    SafePlace(
      id: 'sp5',
      name: 'Shell Fuel Station HSR',
      category: 'petrol',
      latitude: 12.9150,
      longitude: 77.6380,
      address: 'Outer Ring Rd, HSR Layout, Bengaluru',
      phone: '080-25721111',
      is24x7: true,
    ),
  ];

  static final List<Journey> mockJourneys = [
    Journey(
      id: 'j1',
      from: 'Indiranagar',
      to: 'Koramangala',
      date: 'Jun 23, 2026',
      time: '19:30',
      status: 'completed',
      duration: '22 mins',
      routeType: 'safest',
      progress: 1.0,
    ),
    Journey(
      id: 'j2',
      from: 'HSR Layout',
      to: 'MG Road',
      date: 'Jun 22, 2026',
      time: '21:15',
      status: 'sos',
      duration: '15 mins',
      routeType: 'fastest',
      progress: 0.6,
    ),
    Journey(
      id: 'j3',
      from: 'Whitefield',
      to: 'Marathahalli',
      date: 'Jun 20, 2026',
      time: '14:00',
      status: 'cancelled',
      duration: '5 mins',
      routeType: 'safest',
      progress: 0.1,
    ),
  ];

  static final List<AppNotification> mockNotifications = [
    AppNotification(
      id: 'n1',
      title: 'SOS Alert Triggered',
      message: 'Your guardian Aarav has been notified of your location.',
      type: 'sos',
      time: '2 mins ago',
      isRead: false,
    ),
    AppNotification(
      id: 'n2',
      title: 'High Risk Zone Entered',
      message: 'You have entered Koramangala Outer Ring Rd. Stay alert!',
      type: 'crime',
      time: '15 mins ago',
      isRead: false,
    ),
    AppNotification(
      id: 'n3',
      title: 'Guardian Added',
      message: 'Rohan Gupta has accepted your guardian request.',
      type: 'guardian',
      time: '1 hour ago',
      isRead: true,
    ),
    AppNotification(
      id: 'n4',
      title: 'Journey Safe Arrival',
      message: 'Your journey to Koramangala has completed safely.',
      type: 'journey',
      time: 'Yesterday',
      isRead: true,
    ),
  ];

  static final List<RoadReport> mockRoadReports = [
    RoadReport(
      id: 'rr1',
      roadName: 'Koramangala 80 Feet Road',
      reporter: 'Aishwarya R.',
      rating: 4.5,
      tags: ['Well Lit', 'CCTV Active', 'Frequent Patrols'],
      comment: 'Very safe road even late at night. Streets are always busy and bright.',
      time: '3 hours ago',
    ),
    RoadReport(
      id: 'rr2',
      roadName: 'HSR Sector 1 Back Alley',
      reporter: 'Pooja K.',
      rating: 2.0,
      tags: ['Poor Lighting', 'Isolated', 'Potholes'],
      comment: 'The streetlights have been broken for a week. Highly suggest avoiding this road after 9 PM.',
      time: '1 day ago',
    ),
  ];

  static final List<Helpline> mockHelplines = [
    Helpline(title: 'Women Helpline', number: '1091', description: 'National emergency service for women in distress'),
    Helpline(title: 'National Emergency', number: '112', description: 'Single emergency helpline for police, fire, health'),
    Helpline(title: 'Police Control Room', number: '100', description: 'Immediate local police assistance'),
    Helpline(title: 'Ambulance', number: '108', description: 'Medical emergencies and trauma care'),
    Helpline(title: 'Student Helpline', number: '1098', description: 'Support and aid for children and students'),
  ];
}
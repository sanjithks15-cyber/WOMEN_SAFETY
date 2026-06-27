import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database with premium safety data...');

  // 1. Seed Crime Zones if none exist
  const crimeZoneCount = await prisma.crimeZone.count();
  if (crimeZoneCount === 0) {
    console.log('Creating Crime Zones...');
    await prisma.crimeZone.createMany({
      data: [
        {
          name: 'Dark Alley Bypass (Near North Sector)',
          latitude: 12.9715987,
          longitude: 77.5945627,
          riskLevel: 'high',
          description: 'Poor street lighting and frequent reports of snatching. Recommended to avoid walking alone after 9 PM.',
          reportsCount: 14,
          lastIncident: 'Snatching reported 2 days ago',
        },
        {
          name: 'Central Metro Outer Ring Road',
          latitude: 12.9806,
          longitude: 77.5928,
          riskLevel: 'medium',
          description: 'Crowded and poorly monitored pedestrian subway. Susceptible to pickpocketing and harassment.',
          reportsCount: 8,
          lastIncident: 'Harassment reported last week',
        },
        {
          name: 'Industrial Layout Corner',
          latitude: 12.9652,
          longitude: 77.6012,
          riskLevel: 'high',
          description: 'Isolated area with minimal CCTV coverage. Police patrols are irregular.',
          reportsCount: 22,
          lastIncident: 'Suspicious activity reported yesterday',
        },
        {
          name: 'Suburban Park Walkway',
          latitude: 12.9882,
          longitude: 77.6134,
          riskLevel: 'low',
          description: 'Generally safe, but has sparse security personnel during early morning/late evening hours.',
          reportsCount: 3,
          lastIncident: 'Minor theft reported 3 weeks ago',
        }
      ],
    });
  }

  // 2. Seed Safe Places if none exist
  const safePlaceCount = await prisma.safePlace.count();
  if (safePlaceCount === 0) {
    console.log('Creating Safe Places...');
    await prisma.safePlace.createMany({
      data: [
        {
          name: 'City Central Police Station',
          category: 'police',
          latitude: 12.972442,
          longitude: 77.593214,
          address: 'Police Headquarters Road, Infantry Division, Ward 52',
          phone: '+91 80 2294 2200',
          is24x7: true,
        },
        {
          name: 'St. Mary General Hospital Emergency',
          category: 'hospital',
          latitude: 12.9758,
          longitude: 77.5982,
          address: 'St. Mary Boulevard, near Metro Station',
          phone: '+91 80 4012 3456',
          is24x7: true,
        },
        {
          name: 'MG Road Metro Station Security Room',
          category: 'metro',
          latitude: 12.9739,
          longitude: 77.6074,
          address: 'Trinity Junction, MG Road',
          phone: '+91 80 2558 8888',
          is24x7: false,
        },
        {
          name: '24/7 Safeway Superstore',
          category: 'store',
          latitude: 12.9688,
          longitude: 77.5902,
          address: 'Corner of Residency Rd and Museum Rd',
          phone: '+91 99000 12345',
          is24x7: true,
        },
        {
          name: 'HP Petrol Pump Shelter & CCTV Zone',
          category: 'petrol',
          latitude: 12.9641,
          longitude: 77.6045,
          address: 'Double Road Cross, Shanthi Nagar',
          phone: '+91 98888 54321',
          is24x7: true,
        }
      ],
    });
  }

  // 3. Seed Road Reports if none exist
  const roadReportCount = await prisma.roadReport.count();
  if (roadReportCount === 0) {
    console.log('Creating Road Reports...');
    await prisma.roadReport.createMany({
      data: [
        {
          roadName: 'Residency Road (Central Stretch)',
          reporterName: 'Neha Sharma',
          rating: 4.8,
          tags: 'Well Lit,Active CCTV,Police Patrolled,Paved Footpath',
          comment: 'Excellent lighting, plenty of shops open late, and regular police patrolling cars visible. Very safe to walk even after midnight.',
        },
        {
          roadName: 'Double Road Corner to Park Lane',
          reporterName: 'Priya Patel',
          rating: 2.2,
          tags: 'Poor Lighting,Isolated,Uneven Footpath',
          comment: 'Half the streetlights here are broken, making it extremely dark and scary to walk. Footpaths are also broken and unsafe.',
        },
        {
          roadName: 'Koramangala 80 Feet Road',
          reporterName: 'Anjali Rao',
          rating: 4.5,
          tags: 'Well Lit,Active CCTV,Crowded',
          comment: 'Lots of restaurants and shops open. Very crowded and active street. Feels extremely secure with guard presence outside banks.',
        }
      ],
    });
  }

  console.log('Database seeding successfully completed.');
}

main()
  .catch((e) => {
    console.error('Error during seeding:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

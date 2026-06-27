const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  console.log("Seeding mass mock data...");

  // Seed Safe Places (20+ items across Bangalore)
  const safePlaces = [];
  const categories = ['police', 'hospital', 'metro', 'store', 'petrol'];
  const baseLat = 12.9716;
  const baseLng = 77.5946;

  for(let i=0; i<30; i++) {
    safePlaces.push({
      name: `Mock Safe Zone ${i+1}`,
      category: categories[i % categories.length],
      latitude: baseLat + (Math.random() - 0.5) * 0.1,
      longitude: baseLng + (Math.random() - 0.5) * 0.1,
      address: `Random Street ${i}, Bengaluru`,
      phone: `080-12345${i.toString().padStart(3, '0')}`,
      is24x7: Math.random() > 0.5
    });
  }

  // Seed Crime Zones
  const crimeZones = [];
  const riskLevels = ['high', 'medium', 'low'];
  for(let i=0; i<25; i++) {
    crimeZones.push({
      name: `Crime Hotspot ${i+1}`,
      latitude: baseLat + (Math.random() - 0.5) * 0.15,
      longitude: baseLng + (Math.random() - 0.5) * 0.15,
      riskLevel: riskLevels[i % riskLevels.length],
      description: `Reported suspicious activity or harassment in area ${i}`,
      reportsCount: Math.floor(Math.random() * 50) + 1,
      lastIncident: new Date(Date.now() - Math.floor(Math.random() * 10000000000)).toISOString()
    });
  }

  // Seed Road Reports
  const roadReports = [];
  const tagsList = ['Well Lit', 'Dark Area', 'Crowded', 'Deserted', 'Police Patrolling', 'CCTV Active'];
  for(let i=0; i<40; i++) {
    roadReports.push({
      roadName: `Route ${i+1} Expressway`,
      reporterName: `Anonymous User ${i}`,
      rating: (Math.random() * 5).toFixed(1) * 1,
      tags: `${tagsList[Math.floor(Math.random()*tagsList.length)]},${tagsList[Math.floor(Math.random()*tagsList.length)]}`,
      comment: `This road feels ${Math.random() > 0.5 ? 'very safe' : 'a bit sketchy'} at night.`
    });
  }

  console.log("Inserting Safe Places...");
  for (const place of safePlaces) {
    await prisma.safePlace.create({ data: place });
  }

  console.log("Inserting Crime Zones...");
  for (const zone of crimeZones) {
    await prisma.crimeZone.create({ data: zone });
  }

  console.log("Inserting Road Reports...");
  for (const report of roadReports) {
    await prisma.roadReport.create({ data: report });
  }

  console.log("Done seeding massive amounts of mock data!");
}

main().catch(console.error).finally(() => prisma.$disconnect());

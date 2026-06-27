const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const places = [
    {
      name: "Cubbon Park Police Station",
      category: "police",
      latitude: 12.9765,
      longitude: 77.5960,
      address: "Cubbon Park Road, Bengaluru",
      phone: "100",
      is24x7: true
    },
    {
      name: "Bowring Hospital",
      category: "hospital",
      latitude: 12.9818,
      longitude: 77.6010,
      address: "Shivajinagar, Bengaluru",
      phone: "108",
      is24x7: true
    },
    {
      name: "MG Road Metro Station",
      category: "metro",
      latitude: 12.9755,
      longitude: 77.6067,
      address: "MG Road, Bengaluru",
      phone: "080-22969300",
      is24x7: false
    },
    {
      name: "24/7 Pharmacy",
      category: "store",
      latitude: 12.9700,
      longitude: 77.5900,
      address: "Brigade Road, Bengaluru",
      phone: "080-12345678",
      is24x7: true
    }
  ];

  for (const place of places) {
    await prisma.safePlace.create({ data: place });
  }
  console.log("Seeded safe places.");
}

main().catch(console.error).finally(() => prisma.$disconnect());

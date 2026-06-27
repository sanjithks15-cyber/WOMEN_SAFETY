-- AlterTable
ALTER TABLE "RoadReport" ADD COLUMN     "userId" TEXT;

-- AddForeignKey
ALTER TABLE "RoadReport" ADD CONSTRAINT "RoadReport_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

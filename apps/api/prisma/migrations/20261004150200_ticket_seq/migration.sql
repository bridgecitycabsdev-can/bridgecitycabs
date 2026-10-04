-- Day 12: atomic support ticket numbering (same pattern as Branch.invoiceSeq).
ALTER TABLE "Branch" ADD COLUMN "ticketSeq" INTEGER NOT NULL DEFAULT 0;

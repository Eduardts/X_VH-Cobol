       IDENTIFICATION DIVISION.
       PROGRAM-ID. IAM-ANOMALY-DETECTION.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCESS-LOG ASSIGN TO "access.log"
           ORGANIZATION IS LINE SEQUENTIAL.
           
       DATA DIVISION.
       FILE SECTION.
       FD ACCESS-LOG.
       01 LOG-RECORD.
          05 USER-ID        PIC X(8).
          05 ACCESS-TIME    PIC 9(14).
          05 RESOURCE-ID    PIC X(12).
          05 ACCESS-TYPE    PIC X(4).
          
       WORKING-STORAGE SECTION.
       01 WS-EOF           PIC X VALUE 'N'.
       01 WS-COUNTERS.
          05 ACCESS-COUNT   PIC 9(5) VALUE 0.
          05 ALERT-COUNT    PIC 9(5) VALUE 0.
          
       01 WS-AI-MODEL.
          05 THRESHOLD      PIC 9(3)V99 VALUE 75.50.
          05 CONFIDENCE     PIC 9(3)V99.
          
       PROCEDURE DIVISION.
       MAIN-LOGIC.
           PERFORM INITIALIZE-PROCESS
           PERFORM PROCESS-LOGS UNTIL WS-EOF = 'Y'
           PERFORM CLEANUP-PROCESS
           STOP RUN.
           
       INITIALIZE-PROCESS.
           OPEN INPUT ACCESS-LOG
           PERFORM LOAD-AI-MODEL.
           
       PROCESS-LOGS.
           READ ACCESS-LOG
               AT END
                   MOVE 'Y' TO WS-EOF
               NOT AT END
                   PERFORM ANALYZE-LOG-ENTRY
           END-READ.
           
       ANALYZE-LOG-ENTRY.
           ADD 1 TO ACCESS-COUNT
           PERFORM CALCULATE-ANOMALY-SCORE
           IF CONFIDENCE < THRESHOLD
               PERFORM GENERATE-ALERT
           END-IF.
           
       CALCULATE-ANOMALY-SCORE.
           CALL 'AI-SCORE-CALCULATOR' USING 
               LOG-RECORD
               WS-AI-MODEL
               CONFIDENCE.
               
       GENERATE-ALERT.
           ADD 1 TO ALERT-COUNT
           CALL 'ALERT-HANDLER' USING LOG-RECORD.
           
       CLEANUP-PROCESS.
           CLOSE ACCESS-LOG.


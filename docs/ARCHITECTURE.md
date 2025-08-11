## Inspection Workflow

```mermaid
flowchart TD
    A[Place Sleeper on Fixture] --> B[Apply Couplant or Start Water Flow]
    B --> C[Start Scan from Bottom]
    C --> D[Ultrasonic Probes Move Linearly]
    D --> E[Collect A-scan / B-scan Data]
    E --> F[Analyze Echo Signals]
    F --> G{Defect Detected?}
    G -->|Yes| H[Mark Sleeper for Rejection / Repair]
    G -->|No| I[Log and Approve Sleeper]

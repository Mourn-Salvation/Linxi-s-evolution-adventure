# ADR 0001: Godot 2D Belt-Scrolling Runtime

## Status

Accepted

## Decision

Build the demo in Godot 4 using 2D scenes, sprite animation, lane-depth movement, and Y-sorting. Simulated airborne height remains separate from ground position.

## Consequences

The project gets direct control over arcade combat timing and a straightforward sprite pipeline. It does not require a 3D world, skeletal 3D assets, or perspective camera physics.


// Ascent v0.0.1
// Juuso Valli

FUNCTION ASCENT_ANGLE {
	PARAMETER current_altitude.
	PARAMETER target_altitude.
	LOCAL relative_altitude IS MAX(0, MIN(1, current_altitude/target_altitude)).
	RETURN 90 * (1 / (1 + ABS(relative_altitude))).
}

LOCAL previousMax IS "unset".

FUNCTION STAGE_IF_NEEDED {
	IF previousMax = "unset" {
		SET previousMax TO MAXTHRUST.
	}
	IF previousMax > MAXTHRUST + 10 {
		LOCAL oldThrottle IS THROTTLE.
		LOCK THROTTLE TO 0. 
		WAIT 1. STAGE. WAIT 1. 
		LOCK THROTTLE TO oldThrottle.
		SET previousMax TO MAXTHRUST.
	}
}



FUNCTION LAUNCH {
	PARAMETER target_altitude.
	PARAMETER direction.
	
	PRINT "Launching to eastbound LKO".
	PRINT "Initializing controls".
	LOCAL ascent_heading IS HEADING(direction, ASCENT_ANGLE(SHIP:ALTITUDE, target_altitude)).
	LOCK STEERING TO ascent_heading.
	SAS ON.
	SET SASMODE TO "STABILITYASSIST".
	PRINT "Main throttle up.".
	LOCK THROTTLE TO 1.0.
	PRINT "Counting down".
	FROM {local countdown is 5.} UNTIL countdown = 0 STEP {SET countdown to countdown -1.} DO {
		PRINT "..." + countdown.
		WAIT 1.
	}
	// LAUNCH
	PRINT "Liftoff.".
	STAGE.
	
	LOCAL apo_is_not_close IS TRUE.
	
	UNTIL SHIP:OBT:APOAPSIS > target_altitude {
		SET ascent_heading TO HEADING(direction, ASCENT_ANGLE(SHIP:ALTITUDE, target_altitude)).
		STAGE_IF_NEEDED().
		IF apo_is_not_close AND SHIP:OBT:APOAPSIS > target_altitude*0.95 {
			LOCK THROTTLE TO 0.1.
			SET apo_is_not_close TO FALSE.
		}
		WAIT 0.1.
	}
	
	PRINT "Cutting throttle, coasting to apoapsis".
	LOCK THROTTLE TO 0.0.

	WAIT UNTIL ETA:APOAPSIS < 20.
	
	SET ascent_heading TO PROGRADE.
	
	LIGHTS ON.
	LOCK THROTTLE TO 1.0.
	WAIT UNTIL SHIP:OBT:PERIAPSIS > target_altitude*0.95.
	LOCK THROTTLE TO 0.1.
	WAIT UNTIL SHIP:OBT:PERIAPSIS > target_altitude.
	LOCK THROTTLE TO 0.0.
	WAIT 2.
}
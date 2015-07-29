// Boot script v0.0.1
// Juuso Valli

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

FUNCTION HAS_FILE {
	PARAMETER name.
	PARAMETER vol.
	
	SWITCH TO vol.
	LIST FILES IN allFiles.
	FOR file IN allFiles {
		IF file:NAME = name {
			SWITCH TO 1.
			RETURN TRUE.
		}
	}
	SWITCH TO 1.
	RETURN FALSE.
}

FUNCTION DOWNLOAD {
	PARAMETER name.
	if HAS_FILE(name, 0) {
		IF HAS_FILE(name, 1) {
			DELETE name.
		}	
		COPY name FROM 0.
	}
}

FUNCTION UPLOAD {
	PARAMETER name.
	IF HAS_FILE(name, 1) {
		IF HAS_FILE(name, 0) {
			SWITCH TO 0. DELETE name. SWITCH TO 1.
		}
		COPY name TO 0.
	}
}

FUNCTION NEAR_VALUE {
	PARAMETER value1.
	PARAMETER value2.
	PARAMETER epsilon.
	RETURN ABS(value1 - value2) < epsilon.
}

FUNCTION AT_KSC {
	RETURN SHIP:BODY:NAME = "Kerbin" AND NEAR_VALUE(SHIP:LONGITUDE, -75, 1) AND NEAR_VALUE(SHIP:LATITUDE, 0, 1) AND NEAR_VALUE(SHIP:ALTITUDE, 0, 200).
}


// Read instructions from server
SET updateScript TO SHIP:NAME + ".update.ks".
SET launchScript TO SHIP:NAME + ".launch.ks".

// Launch
IF ADDONS:RT:HASCONNECTION(SHIP) {
	IF(AT_KSC() AND HAS_FILE(launchScript, 0)) {
		DOWNLOAD(launchScript).
		IF HAS_FILE("launch.ks", 1) {
			delete launch.ks.
		}
		RENAME launchScript to "launch.ks".
		run launch.ks.
		delete launch.ks.
	}
}


// Load updates
IF ADDONS:RT:HASCONNECTION(SHIP) {
	
	IF(HAS_FILE(updateScript, 0)) {
		DOWNLOAD(updateScript).
		SWITCH TO 0. DELETE updateScript. SWITCH TO 1.
		IF HAS_FILE("update.ks", 1) {
			delete update.ks.
		}
		RENAME updateScript TO "update.ks".
		run update.ks.
		delete update.ks.
	}
}

IF HAS_FILE("startup.ks", 1) {
	RUN startup.ks.
} ELSE {
	wait until addons:rt:hasconnection(ship).
	wait 10.
	reboot.
}
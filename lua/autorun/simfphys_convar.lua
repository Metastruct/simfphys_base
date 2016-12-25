CreateConVar( "sv_simfphys_devmode", "1", {FCVAR_REPLICATED , FCVAR_ARCHIVE},"1 = enabled, 0 = disabled   (requires a restart)" )
CreateConVar( "sv_simfphys_enabledamage", "1", {FCVAR_REPLICATED , FCVAR_ARCHIVE},"1 = enabled, 0 = disabled" )
CreateConVar( "sv_simfphys_lightmode", "2", {FCVAR_REPLICATED , FCVAR_ARCHIVE},"0 = disable all lights, 1 = front only, 2 = enable everything, 3 = highbeams only" )
CreateConVar( "sv_simfphys_gib_lifetime", "30", {FCVAR_REPLICATED , FCVAR_ARCHIVE},"How many seconds before removing the gibs (0 = never remove)" )

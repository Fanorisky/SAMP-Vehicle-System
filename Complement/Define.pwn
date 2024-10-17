//-- SERVER
#define SERVER_VERSION "v1.0.0 Stable " //(Server Version akan terus bertambah setiap update)

#if !defined BCRYPT_HASH_LENGTH
	#define BCRYPT_HASH_LENGTH 250
#endif

#if !defined BCRYPT_COST
	#define BCRYPT_COST 12
#endif

//////////////////////////////////////////////////////////////////////////////
//-- UTILITY
#define forex(%0,%1) for(new %0 = 0; %0 < %1; %0++)

#define FUNC::%0(%1) forward %0(%1); public %0(%1)

#define IsNull(%1) \
((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))


#define Player:: P_ //Player Data variable namespace
#define User:: U_ //User Data variable namespace
#define Character:: C_ //Character Data variable namespace
//////////////////////////////////////////////////////////////////////////////
//-- KEY
#define PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

#define PRESSING(%0,%1) \
	(%0 & (%1))

#define RELEASE(%0) (((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

//////////////////////////////////////////////////////////////////////////////
//-- MAX Defined
#define MAX_CHARS					5
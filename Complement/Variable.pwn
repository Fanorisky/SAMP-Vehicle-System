//============= | Global Data | =============//
new g_RaceCheck[MAX_PLAYERS char];

//============= | User Data | =============//
enum e_User_Data
{
    User::ID,
    User::Time,
    User::CharList,
    User::Admin,
    User::Email[48],
    bool: User::Active,
    bool: User::AutoLogIn
};
new UserData[MAX_PLAYERS][e_User_Data];

enum e_Character_Data
{
    Character::Name[MAX_PLAYER_NAME + 1],
    Character::LastLogin,
    Character::Level,
    Character::Money,
    Character::Bank,
    Character::Gender,
    Character::Skin
}
new CharacterData[MAX_PLAYERS][MAX_CHARS][e_Character_Data];

//============= | Player Data | =============//
/* This thing is important as fuck */
enum e_player_data
{
    Player::ID,
    Player::User[22],
    Player::Name[MAX_PLAYER_NAME],
    Float: Player::Pos[3],
    Float: Player::Angle,
    bool: Player::Spawned,
    Player::World,
    Player::Interior,
    Player::Skin,
    Player::Gender,
    Float: Player::Health,
    Float: Player::Armour,
    Player::Hunger,
    Player::Thirst,
    Player::Money,
    Player::Admin,
    Player::Aduty,
    Player::Level,
    Player::Exp,
};

new PlayerData[MAX_PLAYERS][e_player_data];
local ObjectTypeEnum =
{
    Object = 0x00000001,
    Static = 0x00000002,
    Ctrl = 0x00000004,
    Common = 0x00000008,
    DropItem = 0x00000010,
    Effect = 0x00000020,
    Sprite = 0x00000040,
    Player = 0x00000080,
    Monster = 0x00000100,
    Npc = 0x00000200,
    Pet = 0x00000400,
    Bullet = 0x00000800,
    Trigger = 0x00001000,
    MagicArea = 0x00002000,
    Robot = 0x00004000,
    PickPoint = 0x00008000,
    Missile = 0x00010000,
    ClientObj = 0x01000000,
    ClientBuilding = 0x02000000,
    Mount = 0x04000000,
    OutLook = 0x08000000,
}

return ObjectTypeEnum
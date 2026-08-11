-- item_pose.lua

local GRAVITY = 0.04
local DAMPING = 0.85
local INTENSITY = 0.15

local bowGRAVITY = 0.25
local bowDAMPING = 0.8
local bowINTENSITY = 0.28
local l = (context.bl and 1) or -1


function easeCustom(t)
    local t2 = t * t
    local t3 = t2 * t
    return 3 * t * (1 - t) * (1 - t) * 0.44 +
            3 * t2 * (1 - t) * 1 +
            t3
end

function easeCustomSec(t)
    local t2 = t * t
    local t3 = t2 * t
    return 3 * t * (1 - t) * (1 - t) * 0.44 +
            3 * t2 * (1 - t) * 0.94 +
            t3
end

global.crossBowM = 0.0;
global.swordAttack2 = 0;
global.swordAttack = 0;
global.crossBowSecM = 0.0;
global.crossBowO = 0.0;
global.crossBowSecO = 0.0;
global.walk = 0.0;
global.blockRender = true;
global.walkSmoother = 0.0;
global.swimSmoother = 0.0;
global.swimCounter = 0.0;
global.mainHandSwitch = 0.0;
global.offHandSwitch = 0.0;
global.swingCountPrev = 0;
global.swingOHandPrev = false;
global.swingMHandPrev = false;
global.inspectionCounter = 0.0;
global.inspectionSpin = 0.0;
global.prevAge = 0.0;
global.bowCountO = 0.0;
global.bowCountSecO = 0.0;
global.bowCount = 0.0;
global.bowCountSec = 0.0;
global.bowPullSpeed = 0.0;
global.bowPullAngle = 0.0;
global.bowPullSpeedO = 0.0;
global.bowPullAngleO = 0.0;
global.mapSmoother = 0.0;
global.mapTransition = 0.0;
global.mapZoomer = 0.0;
global.fall = 0.0;
global.a = 0.0;
global.prevPitch = 0.0;
global.pitchSpeed = 0.0;
global.pitchAngle = 0.0;

global.pitchSpeedO = 0.0;
global.pitchAngleO = 0.0;

global.yawSpeedO = 0.0;
global.yawAngleO = 0.0;

global.prevYaw = 0.0;
global.yawSpeed = 0.0;
global.yawAngle = 0.0;
global.mainHandSwitch = 0.0;
global.offHandSwitch = 0.0;

global.foodCount = 0.0;
global.foodCountSec = 0.0;
global.foodCountSecO = 0.0;
global.foodCountO = 0.0;
global.brushCounter = 0.0;
global.brushCounterO = 0.0;
global.shieldDisable = 0.0;
global.shieldM = 0.0;
global.shieldO = 0.0;
global.sneak = 0.0;

global.bundleCounter = 0.0;

global.brushSpeedM = 0;
global.brushSpeedO = 0;
global.brushAngleM = 0;
global.brushAngleO = 0;

global.tridentM = 0;
global.tridentMO = 0;
global.tridentJ = 0;
global.tridentJO = 0;
global.spearCounterM = 0;
global.spearUsageTime = 0;
global.canDismountCounter = 0;
global.canKnockbackCounter = 0;

global.spearCounterO = 0;
global.canDismountCounterO = 0;
global.canKnockbackCounterO = 0;


global.hitImpactCounter = 0;
global.hitImpactCounterO = 0;

brushSpeedM = brushSpeedM + (M:sin(foodCountSec * 4.14) * brushCounter) * context.deltaTime * 30
brushSpeedM = brushSpeedM - GRAVITY * brushAngleM * context.deltaTime * 30
brushSpeedM = brushSpeedM * M:pow(DAMPING, context.deltaTime * 30)
brushAngleM = brushAngleM + brushSpeedM * context.deltaTime * 30

brushSpeedO = brushSpeedO + (M:sin(foodCountSecO * 4.14) * brushCounterO) * context.deltaTime * 30
brushSpeedO = brushSpeedO - GRAVITY * brushAngleO * context.deltaTime * 30
brushSpeedO = brushSpeedO * M:pow(DAMPING, context.deltaTime * 30)
brushAngleO = brushAngleO + brushSpeedO * context.deltaTime * 30


local swingHandPrev = (context.mainHand and swingMHandPrev) or swingOHandPrev
-- local easedBowSec = Easings:easeOutBack(bowCountSec);
-- bowPullSpeed = bowPullSpeed + easedBowSec * bowINTENSITY * context.deltaTime * 30;
-- bowPullSpeed = bowPullSpeed - bowGRAVITY * bowPullAngle * context.deltaTime * 30;
-- bowPullSpeed = bowPullSpeed * M:pow(bowDAMPING, context.deltaTime * 30);

-- bowPullAngle = bowPullAngle + bowPullSpeed * context.deltaTime * 30;

-- if(I:getUseAction(renderedItem) == "bow") then
-- 	M:scale(mat, 1, 1, 1 + bowPullAngle * 0.125);
-- end

renderAsBlock:put("minecraft:string", false)
renderAsBlock:put("minecraft:resin_clump", false)
renderAsBlock:put("minecraft:vine", false)
renderAsBlock:put("minecraft:bamboo", false)

local sp = I:getUseAction(P:getMainItem(context.player)) == "spear" and 1 or 0;
local spo = I:getUseAction(P:getOffhandItem(context.player)) == "spear" and 1 or 0;
local sc = context.mainHand and spearCounterM or spearCounterO
local scd = context.mainHand and canDismountCounter or canDismountCounterO
local sck = context.mainHand and canKnockbackCounter or canKnockbackCounterO
local sw = context.mainHand and mainHandSwitch or offHandSwitch

local mat = context.matrices

-- PERSONAL-TWEAK: pull held items 1 texture pixel (0.0625 block unit) inward on X.
-- l = 1 for right arm, -1 for left arm, so -0.0625 * l always moves toward body center.
M:moveX(mat, -0.0625 * l)

local hic = context.mainHand and Easings:easeInOutSine(hitImpactCounter) or hitImpactCounterO
pitchSpeed = pitchSpeed + ((P:getSpeed(context.player) * 22 * walkSmoother * -1) - (M:sin(context.mainHandSwingProgress * 3.14)) * 8 + fall * 3 + M:sin(sneak * 3.14) * 0.3 + (P:getPitch(context.player) - prevPitch)) * INTENSITY * context.deltaTime * 30
if I:getUseAction(context.item) == "block" and context.mainHand and not I:isIn(context.item, Tags:getVanillaTag("swords")) then
    pitchSpeed = pitchSpeed + 10 * M:sin(shieldDisable * 3.14) * INTENSITY * context.deltaTime * 30
    pitchSpeed = pitchSpeed + 12 * M:sin(shieldM * 3.14) * INTENSITY * context.deltaTime * 30
end
pitchSpeed = pitchSpeed + ((-20 * M:sin(canDismountCounter * 3.14) * spearCounterM) + (20 * M:sin(canKnockbackCounter * 3.14) * spearCounterM) + (12 * M:sin(inspectionCounter * 3.14)) + (15 * M:sin(spearCounterM * 3.14)) + (-10 * M:clamp(M:sin(Easings:easeInBack(hitImpactCounter) * 6.28), 0, 1)) + (40 * M:clamp(M:sin(M:clamp(mainHandSwitch * 1.5 * sp, 0, 1) * 6.28), 0, 1))) * INTENSITY * context.deltaTime * 30
pitchSpeed = pitchSpeed - GRAVITY * pitchAngle * context.deltaTime * 30
pitchSpeed = pitchSpeed * M:pow(DAMPING, context.deltaTime * 30)
pitchAngle = pitchAngle + pitchSpeed * context.deltaTime * 30

yawSpeed = yawSpeed + (M:sin(walk) * 3 * walkSmoother + (M:sin(context.mainHandSwingProgress * 3.14)) * 8 + M:sin(swimCounter * swimSmoother) * 3 + M:sin(mainHandSwitch * 6.28) * 3 + P:getYaw(context.player) - prevYaw) * INTENSITY * context.deltaTime * 30
yawSpeed = yawSpeed - GRAVITY * yawAngle * context.deltaTime * 30
yawSpeed = yawSpeed * M:pow(DAMPING, context.deltaTime * 30)
yawAngle = yawAngle + yawSpeed * context.deltaTime * 30
----------------------------------------------------------------------------------------------------------------
pitchSpeedO = pitchSpeedO + ((P:getSpeed(context.player) * 22 * walkSmoother * -1) - (M:sin(context.offHandSwingProgress * 3.14)) * 8 + fall * 3 + M:sin(sneak * 3.14) * 0.3 + (P:getPitch(context.player) - prevPitch)) * INTENSITY * context.deltaTime * 30
if I:getUseAction(context.item) == "block" and not context.mainHand and not I:isIn(context.item, Tags:getVanillaTag("swords")) then
    pitchSpeedO = pitchSpeedO + 10 * M:sin(shieldDisable * 3.14) * INTENSITY * context.deltaTime * 30
    pitchSpeedO = pitchSpeedO + 12 * M:sin(shieldO * 3.14) * INTENSITY * context.deltaTime * 30
end
pitchSpeedO = pitchSpeedO + ((-20 * M:sin(canDismountCounterO * 3.14) * spearCounterO) + (20 * M:sin(canKnockbackCounterO * 3.14) * spearCounterO) + (15 * M:sin(spearCounterO * 3.14)) + (40 * M:clamp(M:sin(M:clamp(offHandSwitch * 1.5 * spo, 0, 1) * 6.28), 0, 1))) * INTENSITY * context.deltaTime * 30
pitchSpeedO = pitchSpeedO - GRAVITY * pitchAngleO * context.deltaTime * 30
pitchSpeedO = pitchSpeedO * M:pow(DAMPING, context.deltaTime * 30)
pitchAngleO = pitchAngleO + pitchSpeedO * context.deltaTime * 30

yawSpeedO = yawSpeedO + (M:sin(walk) * 3 * walkSmoother + (M:sin(context.offHandSwingProgress * 3.14)) * 8 + M:sin(swimCounter * swimSmoother) * 3 + M:sin(offHandSwitch * 6.28) * 3 + P:getYaw(context.player) - prevYaw) * INTENSITY * context.deltaTime * 30
yawSpeedO = yawSpeedO - GRAVITY * yawAngleO * context.deltaTime * 30
yawSpeedO = yawSpeedO * M:pow(DAMPING, context.deltaTime * 30)
yawAngleO = yawAngleO + yawSpeedO * context.deltaTime * 30

local ywAngle = (context.mainHand and yawAngle) or yawAngleO
local ptAngle = (context.mainHand and pitchAngle) or pitchAngleO
-- local swing = M:sin(context.swingProgress * 3.14);
-- 		swing = swing * swing * swing;
-- 		M:moveY(mat, -0.2 * swing);
-- 		M:moveZ(mat, -0.1 * swing);

-- 		M:rotateX(mat, -50 * swing);

if I:isIn(context.item, Tags:getVanillaTag("pickaxes")) then
    context.swingProgress = easeCustom(context.swingProgress)
else
    context.swingProgress = easeCustomSec(context.swingProgress)
end

local swing_rot
if context.swingProgress < 0.70016 then
    swing_rot = M:sin(M:clamp(context.swingProgress, 0, 0.308) * 5.1)
else
    swing_rot = M:sin(M:clamp(context.swingProgress, 0.70016, 1) * 5.1 - 2)
end

local swing_sword_tilt
if context.swingProgress < 0.65245 then
    swing_sword_tilt = M:sin(M:clamp(context.swingProgress, 0, 0.16675) * 3.14 * 3)
else
    swing_sword_tilt = M:sin(M:clamp(context.swingProgress, 0.65245, 1) * 4.4 - 1.3)
end

swing_rot = swing_rot * swing_rot * swing_rot
local swing = M:clamp(M:sin(context.swingProgress * 4.78), 0, 1)
local swing_hit = M:sin(M:clamp(context.swingProgress, 0.16561, 0.49422) * 4.78 * 2 + 4.7)
local swingOverall = M:sin(context.swingProgress * 3.14)
local swingRise = M:clamp(M:sin(context.swingProgress * 6.28), 0, 1)
local swingRiseS = M:sin(context.swingProgress * 6.28)

local swing_hit_second
if context.swingProgress < 0.65594 then
    swing_hit_second = M:sin(M:clamp(context.swingProgress, 0.16561, 0.32991) * 4.78 * 2 + 4.7)
else
    swing_hit_second = M:sin(M:clamp(context.swingProgress, 0.65594, 0.82025) * 4.78 * 2 - 4.7)
end
if I:getUseAction(context.item) == "spear" then
   M:rotateZ(mat, 180 * l)

   M:rotateZ(mat, -180 * Easings:easeInOutBack(M:clamp(sw * 2, 0, 1)) * l)
   M:moveZ(mat, -0.2 * Easings:easeInOutSine(Easings:easeInOutBack(sc * 0.8)))

   M:moveY(mat, -0.05 * Easings:easeInOutBack(scd))

   M:rotateX(mat, -70 * Easings:easeInOutBack(sc * 0.8))
   M:rotateX(mat, -8 * Easings:easeInOutBack(scd))
   M:rotateY(mat, 60 * Easings:easeInOutBack(sc * 0.8) * l)
   M:rotateY(mat, -30 * Easings:easeInOutBack(scd) * l)

   --M:rotateY(mat, 10 * M:sin(canKnockbackCounter * 3.14) * l)
   M:rotateY(mat, -60 * Easings:easeOutBack(sck) * sck * l)
   --M:rotateZ(mat, -20 * Easings:easeInOutBack(M:sin(spearCounterM * 3.14) * 0.8))

    M:moveY(mat, -0.25 * M:clamp(M:sin(Easings:easeInOutSine(hic) * 6.28), 0, 1))

end
if (I:getUseAction(context.item) ~= "block" and I:getUseAction(context.item) ~= "crossbow") or I:isIn(context.item, Tags:getVanillaTag("swords")) then
    -- if(not I:isIn(renderedItem, Tags:getVanillaTag("swords"))) then
    M:moveZ(mat, -0.05 * swing_rot)
    M:moveY(mat, -0.05 * swing_rot)
    M:rotateX(mat, 10 * swing_rot)
    M:rotateX(mat, -30 * swing_rot)
    M:rotateX(mat, -10 * swing_hit)

    if not I:isIn(context.item, Tags:getVanillaTag("swords")) then
        if I:getUseAction(context.item) == "trident" or I:getUseAction(context.item) == "spear" then
            -- if not swordAttack then

            -- M:moveZ(mat, 0.1 * swing_rot)
            -- M:moveZ(mat, -0.25 * swing_hit)
            -- M:moveZ(mat, -0.25 * swingOverall)
            -- M:moveY(mat, -0.1 * swing_rot)
            -- end
            if I:getUseAction(context.item) == "spear" then
                --M:moveZ(mat, -0.1 * swing_hit)

            end
            M:moveZ(mat, -0.1 * swing_rot)
            --M:moveZ(mat, -0.3 * swingOverall)
            --M:moveZ(mat, -0.3 * swing_hit)
            --M:moveX(mat, 0.05 * l * swingOverall)
            M:moveY(mat, -0.05 * swing_rot)
            if I:getUseAction(context.item) == "spear" then
                M:moveY(mat, -0.15 * swing_hit)

                M:rotateX(mat, -5 * swing_hit)
            end
            M:rotateX(mat, -10 * swing_rot)
            M:rotateX(mat, -15 * swing_hit)
            if I:getUseAction(context.item) == "trident" then
            M:rotateX(mat, -45 * swingOverall)
            else
            M:rotateX(mat, -45 * swing_sword_tilt)
            end

            M:moveY(mat, 0.05 * swing_hit)
            M:moveY(mat, 0.3 * swingOverall)
            --if not swordAttack then

            -- M:rotateX(mat, -50 * M:clamp(swing_rot * 20, 0, 1))
            -- -- M:rotateZ(mat, -180 * M:clamp(swing_rot * 20, 0, 1))
            -- end

        else
            M:moveZ(mat, -0.05 * swing_rot)
            M:moveY(mat, -0.05 * swing_rot)
            M:rotateX(mat, -10 * swing_rot)
            M:rotateX(mat, -25 * swing_hit)
        end
    end
    -- end

    if I:isIn(context.item, Tags:getVanillaTag("shovels")) then
        M:moveY(mat, 0.12 * swing_sword_tilt)
        M:moveZ(mat, 0.05 * swing_sword_tilt)
        M:rotateX(mat, 10 * swing_sword_tilt)
        M:rotateX(mat, -30 * swingOverall)
        M:rotateX(mat, 20 * swing_rot)
        M:rotateX(mat, 10 * swing_hit_second)
    end
    if I:isIn(context.item, Tags:getVanillaTag("swords")) then
        swing = M:sin(context.swingProgress * 3.14)
        M:moveY(mat, -0.1 * Easings:easeInOutBack(swing))
        if I:isIn(context.item, Tags:getVanillaTag("swords")) then
            M:rotateX(mat, -60 * Easings:easeInOutBack(swing))
        else
            M:rotateX(mat, -30 * Easings:easeInOutBack(swing))
        end
    end
    if I:getUseAction(context.item) == "bow" then
        M:moveX(mat, -0.065 * l)
    end
end

if I:isIn(context.item, Tags:getVanillaTag("beds")) then
    M:moveZ(mat, 0.2)
    M:rotateY(mat, 180 * l, -0.15 * l, -0.4, 0)
end

if I:isOf(context.item, Items:get("minecraft:bell")) or I:isLantern(context.item) or I:isOf(context.item, Items:get("minecraft:end_crystal")) or I:isIn(context.item, Tags:getVanillaTag("hanging_signs")) or I:isOf(context.item, Items:get("minecraft:pink_petals")) or I:isOf(context.item, Items:get("minecraft:leaf_litter")) or I:isOf(context.item, Items:get("minecraft:wildflowers")) then
    if not I:isOf(context.item, Items:get("minecraft:end_crystal")) then
        M:moveY(mat, -0.62)
    end
    if I:isIn(context.item, Tags:getVanillaTag("hanging_signs")) then
        M:moveY(mat, -0.07)
    end
    if I:isOf(context.item, Items:get("minecraft:pink_petals")) or I:isOf(context.item, Items:get("minecraft:leaf_litter")) or I:isOf(context.item, Items:get("minecraft:wildflowers")) then
        M:moveY(mat, 0.4)
        M:rotateX(mat, -70)
    else
        M:moveZ(mat, 0.2)
        M:rotateX(mat, -25)
    end
    if I:isOf(context.item, Items:get("minecraft:pink_petals")) or I:isOf(context.item, Items:get("minecraft:wildflowers")) or I:isOf(context.item, Items:get("minecraft:leaf_litter")) then
        -- M:moveZ(mat, (M:clamp(P:getPitch(context.player) / 2.5, -20, 90) + pitchAngle) / -100)
        -- M:moveY(mat, (M:clamp(P:getPitch(context.player) / 2.5, -20, 90) + pitchAngle) / -100)
        M:rotateX(mat, M:clamp(P:getPitch(context.player) / 2.5, -20, 90) + ptAngle + ywAngle * 0.5, 0, -0.13, 0)
    end
    if I:isOf(context.item, Items:get("minecraft:bell")) or I:isLantern(context.item) or I:isOf(context.item, Items:get("minecraft:end_crystal")) then
        if I:isOf(context.item, Items:get("minecraft:end_crystal")) then
            M:scale(mat, 1 + 0.01 * M:sin(a * 15), 1 + 0.01 * M:sin(a * 15), 1 + 0.01 * M:sin(a * 8))
            M:moveY(mat, 0.03 * M:sin(a * 2))
            M:moveY(mat, 0.25)
            M:moveY(mat, ptAngle / 150)
            M:moveX(mat, ywAngle / 150 * l * -1)
            M:rotateZ(mat, 5 * M:sin(a))
            M:scale(mat, 0.7, 0.7, 0.7)
        elseif I:isOf(context.item, Items:get("minecraft:bell")) then
            M:moveX(mat, 0.15 * l)
            M:moveY(mat, -0.05)
            M:moveZ(mat, -0.1)
            M:scale(mat, 1.2, 1.2, 1.2)
            M:rotateX(mat, M:clamp(P:getPitch(context.player) / 2.5, -20, 90) + ptAngle, -0.1 * l, 0.4, 0.1)
            M:rotateZ(mat, ywAngle * -1, -0.1 * l, 0.4, 0.1)
        else
            M:rotateX(mat, M:clamp(P:getPitch(context.player) / 2.5, -20, 90) + ptAngle, 0, 0.4, 0)
            M:rotateZ(mat, ywAngle * -1, 0, 0.4, 0)
        end
    end
    if I:isIn(context.item, Tags:getVanillaTag("hanging_signs")) then
        M:rotateX(mat, M:clamp(P:getPitch(context.player) / 2.5, -35, 90) + ptAngle, 0, 0.55, 0)
        M:rotateZ(mat, ywAngle * -1, 0, 0.55, 0)
    end
elseif I:isOf(context.item, Items:get("minecraft:painting")) or I:isOf(context.item, Items:get("minecraft:item_frame")) then
    context.swingProgress = 0
    M:rotateX(mat, -25)
    M:moveY(mat, -0.65)
    M:rotateX(mat, M:clamp(P:getPitch(context.player) / 2.5, -25, 90) + ptAngle, 0, 0.45, 0)
    M:rotateZ(mat, ywAngle * -1, 0, 0.55, 0)
elseif I:isBlock(context.item) then
    M:moveY(mat, -0.025)
    M:moveZ(mat, -0.025)
    M:rotateX(mat, -5)
else
    if not I:isBlock(context.item) and not I:isEmpty(context.item) and I:getUseAction(context.item) == "none" and I:getUseAction(context.item) ~= "crossbow" then
        if I:isIn(context.item, Tags:getVanillaTag("axes")) or I:isOf(context.item, Items:get("minecraft:mace")) then
            local ptAngleMultiplier = (I:isOf(context.item, Items:get("minecraft:mace")) and 0.2) or 0.15
            M:rotateX(mat, -20 * M:sin(context.equipProgress * context.equipProgress * context.equipProgress) + (ptAngle * ptAngleMultiplier), 0.3 * l, -0.3, 0)
        else
            M:rotateX(mat, -20 * M:sin(context.equipProgress * context.equipProgress * context.equipProgress) + (ptAngle * 0.05), 0.3 * l, -0.4, 0)
        end
    end
    if (I:isIn(context.item, Tags:getVanillaTag("axes")) or I:isOf(context.item, Items:get("minecraft:mace"))) and I:getUseAction(context.item) ~= "crossbow" then
        M:rotateX(mat, (P:getPitch(context.player) * -0.05) + ptAngle * 0.2, 0, -0.2, 0)
    elseif I:getUseAction(context.item) ~= "crossbow" then
        M:rotateX(mat, (P:getPitch(context.player) * -0.025) + ptAngle * 0.1, 0, -0.2, 0)
    end
end
-- if(not I:isIn(renderedItem, ConventionalItemTags.TOOLS) and not I:isIn(renderedItem, Tags:getVanillaTag("swords"))) then
-- 	M:rotateX(mat, 10)
-- 	M:rotateZ(mat, 10 * l)
-- 	M:rotateY(mat, -30 * l)
-- end
-- if (context.mainHand) then
-- 	local switchItems = M:sin(M:clamp(mainHandSwitch, 0, 0.5) * 3.14);
-- 	local switch_fast = M:sin(M:clamp(mainHandSwitch, 0, 0.125) * 12.56);
-- 	switchItems = Easings:easeInOutBack(switchItems);
-- 	M:rotateX(mat, -70 * switch_fast, 0, -0.2, 0);
-- 	M:rotateZ(mat, 40 * switch_fast);
-- 	M:rotateZ(mat, -40 * switch_fast);
-- 	M:rotateX(mat, 70 * switchItems, 0, -0.2, 0);
-- else
-- 	local switchItems = M:sin(M:clamp(offHandSwitch, 0, 0.5) * 3.14);
-- 	local switch_fast = M:sin(M:clamp(offHandSwitch, 0, 0.125) * 12.56);
-- 	switchItems = Easings:easeInOutBack(switchItems);
-- 	M:rotateX(mat, -70 * switch_fast, 0, -0.2, 0);
-- 	M:rotateZ(mat, 40 * l * switch_fast);
-- 	M:rotateZ(mat, -40 * l * switch_fast);
-- 	M:rotateX(mat, 70 * switchItems, 0, -0.2, 0);
-- end

if (I:getUseAction(context.item) == "drink" or I:getUseAction(context.item) == "eat" or I:getUseAction(context.item) == "toot_horn") and context.mainHand then
    M:moveX(mat, 0.02 * l * foodCount)
    M:moveZ(mat, -0.05 * foodCount)
    if I:getUseAction(context.item) == "eat" or I:getUseAction(context.item) == "toot_horn" then
        M:rotateX(mat, -23 * foodCount * foodCount)
        M:rotateZ(mat, -12 * l * foodCount * foodCount)
    end
    M:rotateY(mat, -50 * l * foodCount * foodCount)

    if I:getUseAction(context.item) == "drink" then
        M:rotateX(mat, 15 * foodCount * foodCount)
    end
end

if (I:getUseAction(context.item) == "drink" or I:getUseAction(context.item) == "eat" or I:getUseAction(context.item) == "toot_horn") and not context.mainHand then
    M:moveX(mat, 0.02 * l * foodCountO)
    M:moveZ(mat, -0.05 * foodCountO)
    if I:getUseAction(context.item) == "eat" or I:getUseAction(context.item) == "toot_horn" then
        M:rotateX(mat, -23 * foodCountO * foodCountO)
        M:rotateZ(mat, -12 * l * foodCountO * foodCountO)
    end
    M:rotateY(mat, -50 * l * foodCountO * foodCountO)

    if I:getUseAction(context.item) == "drink" then
        M:rotateX(mat, 15 * foodCountO * foodCountO)
    end
end

if I:getUseAction(context.item) == "brush" and context.mainHand then
    M:moveZ(mat, -0.03 * Easings:easeInOutBack(brushCounter))
    M:rotateX(mat, -30 * Easings:easeInOutBack(brushCounter))
    M:rotateZ(mat, 15 * l * M:sin((foodCountSec - 0.5) * 4.14) * Easings:easeInOutBack(brushCounter))
    M:rotateZ(mat, l * brushAngleM)
end
if I:getUseAction(context.item) == "brush" and not context.mainHand then
    M:moveZ(mat, -0.03 * Easings:easeInOutBack(brushCounterO))
    M:rotateX(mat, -30 * Easings:easeInOutBack(brushCounterO))
    M:rotateZ(mat, 15 * l * M:sin((foodCountSecO - 0.5) * 4.14) * Easings:easeInOutBack(brushCounterO))
    M:rotateZ(mat, l * brushAngleO)
end

if I:isIn(context.item, Tags:getVanillaTag("doors")) then
    M:moveX(mat, 0.1 * l)
    M:moveZ(mat, 0.25)
    M:moveY(mat, -0.35)
    M:rotateZ(mat, -10 * l)
    M:rotateY(mat, -90 * l)
elseif I:isIn(context.item, Tags:getVanillaTag("beds")) then
    M:moveZ(mat, 0.17)
    M:rotateY(mat, -35 * l, 0.3 * l, -0.4, 0)
    M:scale(mat, 0.9, 0.9, 0.9)
end

if I:isOf(context.item, Items:get("minecraft:slime_ball")) or I:isOf(context.item, Items:get("minecraft:slime_block")) or I:isOf(context.item, Items:get("minecraft:honey_block")) then
    if I:isOf(context.item, Items:get("minecraft:slime_ball")) then
        M:moveY(mat, -0.1)
        local scaleY = (fall < 0 and fall * 0.06) or fall * 0.12
        M:scale(mat, 1, 1 + scaleY, 1)
        M:moveY(mat, 0.1)
    else
        local scaleX_Z = (fall < 0 and fall * 0.05) or fall * 0.1
        local scaleY = (fall < 0 and fall * 0.1) or fall * 0.3
        M:moveY(mat, -0)
        M:scale(mat, 1 - scaleX_Z, 1 + scaleY, 1 - scaleX_Z)
        M:moveY(mat, 0)

        if context.bl then
            M:shear(mat, 0, 0 - ywAngle * 0.006, 0)
        else
            M:shear(mat, 0, 0 + ywAngle * 0.006, 0)
        end
    end
end

if I:isIn(context.item, Tags:getVanillaTag("shovels")) then
    M:moveX(mat, -0.09 * l)
    M:rotateY(mat, 80 * l)
end
prevPitch = P:getPitch(context.player)
prevYaw = P:getYaw(context.player)

-- context.bl == true -- right
-- context.bl == false -- left

local autoFlip = (context.bl and 1) or -1

if I:isOf(context.item, Items:get("minecraft:magma_cream")) then
    M:scale(mat, 1 - (fall / 5), 1 + (fall / 5), 1)
end

local switch_val = (context.mainHand and mainHandSwitch) or offHandSwitch
local musicDiscHandTilt
if switch_val < 0.65245 then
    musicDiscHandTilt = M:sin(M:clamp(switch_val, 0, 0.16675) * 3.14 * 3)
else
    musicDiscHandTilt = M:sin(M:clamp(switch_val, 0.65245, 1) * 4.4 - 1.3)
end
local musicDiscHandJump = M:sin(M:clamp(switch_val, 0.52459, 0.85809) * 3.14 * 3 - 1.8)
-- if(I:isIn(renderedItem, Tags:getVanillaTag("music_discs"))) then
-- 	M:rotateX(mat, -45 * musicDiscHandTilt);
-- 	M:moveZ(mat, -0.2 * musicDiscHandTilt)
-- 	M:moveY(mat, -0.05 * Easings:easeInBack(musicDiscHandJump))
-- 	M:moveY(mat, 0.1)
-- 	M:moveZ(mat, -0.07)
-- 	M:rotateY(mat, 360 * Easings:easeInOutBack((context.mainHand and mainHandSwitch) or offHandSwitch), 0, 0, 0.2);
-- 	M:rotateX(mat, 90);
-- end

local switchAnimationVariable = Easings:easeInBack(M:sin(M:clamp((context.mainHand and mainHandSwitch) or offHandSwitch, 0.09723, 0.60632) * 3.24 * 1.65 - 0.1))
if (I:isIn(context.item, Tags:getVanillaTag("bundles")) or I:isOf(context.item, Items:get("minecraft:ender_pearl")) or I:isOf(context.item, Items:get("minecraft:ender_eye")) or I:isThrowable(context.item) or I:isIn(context.item, Tags:getFabricTag("music_discs")) or I:isIn(context.item, Tags:getFabricTag("nuggets")) or I:isIn(context.item, Tags:getVanillaTag("skulls"))) and I:getUseAction(context.item) ~= "trident" then
    M:rotateX(mat, -10 * switchAnimationVariable)
    M:moveY(mat, 0.62 * switchAnimationVariable)
    M:moveY(mat, M:clamp(0.1 * fall, 0, 255))

    local switchEvent = (context.mainHand and mainHandSwitchEvent) or offHandSwitchEvent

    if I:isIn(context.item, Tags:getFabricTag("nuggets")) then
        if switchEvent then
            S:playSound("entity.experience_orb.pickup", 0.3)
        end
        M:moveY(mat, -0.07)
        M:rotateX(mat, 360 * Easings:easeInOutBack((context.mainHand and M:clamp(mainHandSwitch * 1.65, 0, 1)) or M:clamp(offHandSwitch * 1.65, 0, 1)), 0, 0.1, 0)
    elseif I:isIn(context.item, Tags:getFabricTag("music_discs")) then
        if switchEvent then
            S:playSound("entity.context.player.attack.weak", 0.3)
        end
        M:rotateZ(mat, 360 * Easings:easeInOutBack((context.mainHand and M:clamp(mainHandSwitch * 1.65, 0, 1)) or M:clamp(offHandSwitch * 1.65, 0, 1)), -0.1 * l, 0.25, 0)
    else
        if switchEvent then
            S:playSound("entity.context.player.attack.weak", 0.3)
        end
        local clampedSwitch = (context.mainHand and M:clamp(mainHandSwitch * 1.2, 0, 1)) or M:clamp(offHandSwitch * 1.2, 0, 1)
        M:rotateZ(mat, -7 * l * M:sin(M:clamp(clampedSwitch, 0.0943, 0.66791) * 7.07 * 1.5 - 0.8))
    end
    -- M:scale(mat, 1 - (switchAnimationVariable * 0.17), 1 + (switchAnimationVariable * 0.17), 1 - (switchAnimationVariable * 0.17))
end

local easedMapTransition = Easings:easeInOutBack(mapTransition)
local easedMapSmoother = Easings:easeInOutBack(mapSmoother)
local easedMapZoomer = Easings:easeInOutBack(mapZoomer)

if I:isOf(context.item, Items:get("minecraft:filled_map")) then
    M:rotateZ(mat, 5 * l * easedMapSmoother)
    M:rotateY(mat, (-40 - (20 * easedMapZoomer)) * l * easedMapSmoother)
    M:rotateZ(mat, 15 * l * easedMapSmoother)
    M:rotateX(mat, -10 * easedMapZoomer * easedMapSmoother)
end
if I:isOf(context.item, Items:get("minecraft:filled_map")) then
    local smoother = 1 - easedMapSmoother
    M:moveZ(mat, -0.05 * smoother)
    M:moveY(mat, -0.05 * smoother)
    M:rotateX(mat, -40 * smoother)
    M:rotateY(mat, -10 * l * smoother)
    M:rotateZ(mat, 5 * l * smoother)
elseif I:shouldTranslateItem(context.item) and not I:isBlock(context.item) and not I:isOf(context.item, Items:get("minecraft:bone")) and I:getUseAction(context.item) ~= "bow" and I:getUseAction(context.item) ~= "spear" then
    M:moveX(mat, -0.05 * l)
    M:moveY(mat, 0.125) -- 5.1.2: raised 2 texture px total (buckets/boats sat too low)
    M:rotateX(mat, -8)
    M:rotateY(mat, -10 * l)
    M:rotateZ(mat, 6 * l)
end

if I:isCustomTranslate(context.item) then
    M:moveX(mat, -0.05 * l)
    M:rotateX(mat, -8)
    M:rotateY(mat, -10 * l)
    M:rotateZ(mat, 6 * l)
end

if I:isOf(context.item, Items:get("minecraft:shears")) then
    if not context.bl then
        M:moveZ(mat, 0.1)
        M:rotateY(mat, 180)
    end
    M:rotateZ(mat, 45)
end
if I:isIn(context.item, Tags:getVanillaTag("skulls")) and not I:isOf(context.item, Items:get("minecraft:dragon_head")) then
    M:moveX(mat, -0.1 * l)
    M:moveY(mat, 0.11)
    M:rotateZ(mat, 15 * l)
    M:rotateY(mat, -85 * l)
    M:rotateX(mat, -55)
    -- M:rotateY(mat, 120 * l)
elseif I:isOf(context.item, Items:get("minecraft:dragon_head")) then
    M:moveY(mat, 0.25)
    M:rotateZ(mat, 6 * l)
    M:rotateY(mat, 160 * l)
end

if (context.mainHand and mainHandSwitchEvent) or offHandSwitchEvent then
    S:playSound("context.item.armor.equip_leather", 0.2)
end

local ticker = function(particle)
    particle.dy = particle.dy + 0.005 * context.deltaTime * 30
    particle.dx = particle.dx + 0.005 * M:sin(context.player.age * 0.5) * context.deltaTime * 30
end

if I:isOf(context.item, Items:get("minecraft:brewing_stand")) or I:isOf(context.item, Items:get("minecraft:redstone_torch")) or I:isOf(context.item, Items:get("minecraft:torch")) or I:isOf(context.item, Items:get("minecraft:lantern")) or I:isOf(context.item, Items:get("minecraft:soul_torch")) or I:isOf(context.item, Items:get("minecraft:soul_lantern")) then
    if I:isOf(context.item, Items:get("minecraft:brewing_stand")) or I:isOf(context.item, Items:get("minecraft:torch")) then
        particleManager:addParticle(context.particles, false, 0.5 * l, 0.6, 0.5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1.3, Texture:of("minecraft", "textures/particle/orange_glow.png"), "ITEM", context.hand, "SPAWN", "ADDITIVE", 0, 200 + (20 * M:sin(P:getAge(context.player) * 0.2)))
    elseif I:isOf(context.item, Items:get("minecraft:lantern")) then
        particleManager:addParticle(context.particles, false, 0.45 * l, 0.15, 0.5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1.3, Texture:of("minecraft", "textures/particle/orange_glow.png"), "ITEM", context.hand, "SPAWN", "ADDITIVE", 0, 200 + (20 * M:sin(P:getAge(context.player) * 0.2)))
    elseif I:isLantern(context.item) and string.find(I:getName(context.item), "copper") then
        particleManager:addParticle(context.particles, false, 0.45 * l, 0.15, 0.5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1.3, Texture:of("minecraft", "textures/particle/orange_glow.png"), "ITEM", context.hand, "SPAWN", "ADDITIVE", 0, 200 + (20 * M:sin(P:getAge(context.player) * 0.2)))
    elseif I:isOf(context.item, Items:get("minecraft:soul_torch")) then
        particleManager:addParticle(context.particles, false, 0.5 * l, 0.6, 0.5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1.3, Texture:of("minecraft", "textures/particle/blue_glow.png"), "ITEM", context.hand, "SPAWN", "ADDITIVE", 0, 110 + (10 * M:sin(P:getAge(context.player) * 0.2)))
    elseif I:isOf(context.item, Items:get("minecraft:soul_lantern")) then
        particleManager:addParticle(context.particles, false, 0.45 * l, 0.15, 0.5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1.3, Texture:of("minecraft", "textures/particle/blue_glow.png"), "ITEM", context.hand, "SPAWN", "ADDITIVE", 0, 110 + (10 * M:sin(P:getAge(context.player) * 0.2)))
    elseif I:isOf(context.item, Items:get("minecraft:redstone_torch")) then
        particleManager:addParticle(context.particles, false, 0.5 * l, 0.6, 0.5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1.3, Texture:of("minecraft", "textures/particle/red_glow.png"), "ITEM", context.hand, "SPAWN", "ADDITIVE", 0, 110 + (10 * M:sin(P:getAge(context.player) * 0.2)))
    end
end


if KeyBindManager:isKeyPressed(${inspectKeybind} ~= 0 and ${inspectKeybind} or 67) then
inspectionSpin = inspectionSpin + 0.025 * context.deltaTime * 30
else
inspectionSpin = 0
end
inspectionSpin = M:clamp(inspectionSpin, 0, 1)

if (I:isIn(context.item, Tags:getVanillaTag("swords")) or I:isIn(context.item, Tags:getVanillaTag("pickaxes")) or I:isIn(context.item, Tags:getVanillaTag("axes")) or I:getUseAction(context.item) == "trident") and context.mainHand then
M:moveX(mat, -0.2 * l * inspectionCounter)
M:rotateX(mat, -360 * Easings:easeInOutBack(inspectionSpin), 0, 0, 0.15)
end
prevAge = P:getAge(context.player)


if swingCountPrev ~= P:getSwingCount(context.player) and context.mainHand and I:isOf(context.item, Items:get("minecraft:bell")) then
S:playSound("block.bell.use", 0.3)
end
swingCountPrev = P:getSwingCount(context.player)


if I:isOf(context.item, Items:get("minecraft:pink_petals")) or I:isOf(context.item, Items:get("minecraft:wildflowers")) or I:isOf(context.item, Items:get("minecraft:leaf_litter")) then
local flower = ""
if I:isOf(context.item, Items:get("minecraft:pink_petals")) then
flower = "pink_petals"
elseif I:isOf(context.item, Items:get("minecraft:wildflowers")) then
flower = "wild_flowers"
elseif I:isOf(context.item, Items:get("minecraft:leaf_litter")) then
flower = "leaf_litter"
end

local particle_ticker = function(particle)
particle.dx = particle.dx + 0.005 * M:sin(P:getAge(context.player) * 0.3) * context.deltaTime * 30
end

if swingMHandPrev ~= context.swingMHand and context.mainHand then
S:playSound("block.leaf_litter.place", 0.7);
local value = math.random() * 0.3
particleManager:addParticle(context.particles, true, 0.75 * l, -0.2, -0.9, (math.random() * 0.12 - 0.06) * l, math.random() * 0.12, 0, 0, 0, 0, 0, 0, 0, 0.4, Texture:of("minecraft", "textures/particle/firefly.png"), "SCREEN", context.hand, "OPACITY", "TRANSLUCENT_L", 1, 255, particle_ticker)
value = math.random() * 0.3
particleManager:addParticle(context.particles, true, 0.75 * l, -0.2, -0.9, (math.random() * 0.12 - 0.06) * l, math.random() * 0.12, 0, 0, 0, 0, 0, 0, 0, 0.4, Texture:of("minecraft", "textures/particle/firefly.png"), "SCREEN", context.hand, "OPACITY", "TRANSLUCENT_L", 1, 255, particle_ticker)
------------------------------------------
particleManager:addParticle(context.particles, true, 0.65 * l, -0.25, -0.9, (math.random() * 0.12 - 0.06) * l, math.random() * 0.12, 0, 0, 0, 0, 0, 0, 0, 0.3, Texture:of("minecraft", "textures/particle/" .. flower .. "_1.png"), "SCREEN", context.hand, "OPACITY", "TRANSLUCENT_L", 1, 255, particle_ticker)
value = math.random() * 0.3
particleManager:addParticle(context.particles, true, 0.65 * l, -0.25, -0.9, (math.random() * 0.12 - 0.06) * l, math.random() * 0.12, 0, 0, 0, 0, 0, 0, 0, 0.3, Texture:of("minecraft", "textures/particle/" .. flower .. "_1.png"), "SCREEN", context.hand, "OPACITY", "TRANSLUCENT_L", 1, 255, particle_ticker)
particleManager:addParticle(context.particles, true, 0.65 * l, -0.25, -0.9, (math.random() * 0.12 - 0.06) * l, math.random() * 0.12, 0, 0, 0, 0, 0, 0, 0, 0.3, Texture:of("minecraft", "textures/particle/" .. flower .. "_2.png"), "SCREEN", context.hand, "OPACITY", "TRANSLUCENT_L", 1, 255, particle_ticker)
value = math.random() * 0.3
particleManager:addParticle(context.particles, true, 0.65 * l, -0.25, -0.9, (math.random() * 0.12 - 0.06) * l, math.random() * 0.12, 0, 0, 0, 0, 0, 0, 0, 0.3, Texture:of("minecraft", "textures/particle/" .. flower .. "_2.png"), "SCREEN", context.hand, "OPACITY", "TRANSLUCENT_L", 1, 255, particle_ticker)
particleManager:addParticle(context.particles, true, 0.65 * l, -0.25, -0.9, (math.random() * 0.12 - 0.06) * l, math.random() * 0.12, 0, 0, 0, 0, 0, 0, 0, 0.2, Texture:of("minecraft", "textures/particle/" .. flower .. "_4.png"), "SCREEN", context.hand, "OPACITY", "TRANSLUCENT_L", 1, 255, particle_ticker)
value = math.random() * 0.3
particleManager:addParticle(context.particles, true, 0.65 * l, -0.25, -0.9, (math.random() * 0.12 - 0.06) * l, math.random() * 0.12, 0, 0, 0, 0, 0, 0, 0, 0.2, Texture:of("minecraft", "textures/particle/" .. flower .. "_4.png"), "SCREEN", context.hand, "OPACITY", "TRANSLUCENT_L", 1, 255, particle_ticker)
elseif swingOHandPrev ~= context.swingOHand and not context.mainHand then
S:playSound("block.leaf_litter.place", 0.7);
local value = math.random() * 0.3
particleManager:addParticle(context.particles, true, 0.75 * l, -0.2, -0.9, (math.random() * 0.12 - 0.06) * l, math.random() * 0.12, 0, 0, 0, 0, 0, 0, 0, 0.4, Texture:of("minecraft", "textures/particle/firefly.png"), "SCREEN", context.hand, "OPACITY", "TRANSLUCENT_L", 1, 255, particle_ticker)
value = math.random() * 0.3
particleManager:addParticle(context.particles, true, 0.75 * l, -0.2, -0.9, (math.random() * 0.12 - 0.06) * l, math.random() * 0.12, 0, 0, 0, 0, 0, 0, 0, 0.4, Texture:of("minecraft", "textures/particle/firefly.png"), "SCREEN", context.hand, "OPACITY", "TRANSLUCENT_L", 1, 255, particle_ticker)
------------------------------------------
particleManager:addParticle(context.particles, true, 0.65 * l, -0.25, -0.9, (math.random() * 0.12 - 0.06) * l, math.random() * 0.12, 0, 0, 0, 0, 0, 0, 0, 0.3, Texture:of("minecraft", "textures/particle/" .. flower .. "_1.png"), "SCREEN", context.hand, "OPACITY", "TRANSLUCENT_L", 1, 255, particle_ticker)
value = math.random() * 0.3
particleManager:addParticle(context.particles, true, 0.65 * l, -0.25, -0.9, (math.random() * 0.12 - 0.06) * l, math.random() * 0.12, 0, 0, 0, 0, 0, 0, 0, 0.3, Texture:of("minecraft", "textures/particle/" .. flower .. "_1.png"), "SCREEN", context.hand, "OPACITY", "TRANSLUCENT_L", 1, 255, particle_ticker)
particleManager:addParticle(context.particles, true, 0.65 * l, -0.25, -0.9, (math.random() * 0.12 - 0.06) * l, math.random() * 0.12, 0, 0, 0, 0, 0, 0, 0, 0.3, Texture:of("minecraft", "textures/particle/" .. flower .. "_2.png"), "SCREEN", context.hand, "OPACITY", "TRANSLUCENT_L", 1, 255, particle_ticker)
value = math.random() * 0.3
particleManager:addParticle(context.particles, true, 0.65 * l, -0.25, -0.9, (math.random() * 0.12 - 0.06) * l, math.random() * 0.12, 0, 0, 0, 0, 0, 0, 0, 0.3, Texture:of("minecraft", "textures/particle/" .. flower .. "_2.png"), "SCREEN", context.hand, "OPACITY", "TRANSLUCENT_L", 1, 255, particle_ticker)
particleManager:addParticle(context.particles, true, 0.65 * l, -0.25, -0.9, (math.random() * 0.12 - 0.06) * l, math.random() * 0.12, 0, 0, 0, 0, 0, 0, 0, 0.2, Texture:of("minecraft", "textures/particle/" .. flower .. "_4.png"), "SCREEN", context.hand, "OPACITY", "TRANSLUCENT_L", 1, 255, particle_ticker)
value = math.random() * 0.3
particleManager:addParticle(context.particles, true, 0.65 * l, -0.25, -0.9, (math.random() * 0.12 - 0.06) * l, math.random() * 0.12, 0, 0, 0, 0, 0, 0, 0, 0.2, Texture:of("minecraft", "textures/particle/" .. flower .. "_4.png"), "SCREEN", context.hand, "OPACITY", "TRANSLUCENT_L", 1, 255, particle_ticker)
end
end

if context.mainHand then
swingMHandPrev = context.swingMHand
else
swingOHandPrev = context.swingOHand
end
local tags = {
    "copper_golem_statues"
}

local itemIds = {
"minecraft:string",
"minecraft:resin_clump",
"minecraft:vine",
"minecraft:kelp",
"minecraft:seagrass",
"minecraft:iron_bars",
"minecraft:glass_pane",
"minecraft:white_stained_glass_pane",
"minecraft:orange_stained_glass_pane",
"minecraft:magenta_stained_glass_pane",
"minecraft:light_blue_stained_glass_pane",
"minecraft:yellow_stained_glass_pane",
"minecraft:lime_stained_glass_pane",
"minecraft:pink_stained_glass_pane",
"minecraft:gray_stained_glass_pane",
"minecraft:light_gray_stained_glass_pane",
"minecraft:cyan_stained_glass_pane",
"minecraft:purple_stained_glass_pane",
"minecraft:blue_stained_glass_pane",
"minecraft:brown_stained_glass_pane",
"minecraft:green_stained_glass_pane",
"minecraft:red_stained_glass_pane",
"minecraft:black_stained_glass_pane",
"minecraft:ladder",
"minecraft:oak_sign",
"minecraft:spruce_sign",
"minecraft:birch_sign",
"minecraft:jungle_sign",
"minecraft:acacia_sign",
"minecraft:dark_oak_sign",
"minecraft:mangrove_sign",
"minecraft:cherry_sign",
"minecraft:bamboo_sign",
"minecraft:crimson_sign",
"minecraft:warped_sign",
"minecraft:pale_oak_sign",
"minecraft:tripwire_hook",
"minecraft:hopper",
"minecraft:cauldron",
"minecraft:rail",
"minecraft:powered_rail",
"minecraft:detector_rail",
"minecraft:activator_rail",
"minecraft:repeater",
"minecraft:comparator",
"minecraft:twisting_vines",
"minecraft:weeping_vines",
"minecraft:sniffer_egg",
"minecraft:candle",
"minecraft:white_candle",
"minecraft:orange_candle",
"minecraft:magenta_candle",
"minecraft:light_blue_candle",
"minecraft:yellow_candle",
"minecraft:lime_candle",
"minecraft:pink_candle",
"minecraft:gray_candle",
"minecraft:light_gray_candle",
"minecraft:cyan_candle",
"minecraft:purple_candle",
"minecraft:blue_candle",
"minecraft:brown_candle",
"minecraft:green_candle",
"minecraft:red_candle",
"minecraft:black_candle",
"minecraft:frogspawn",
"minecraft:light",
"minecraft:structure_void",
"minecraft:barrier",
"minecraft:carrot",
"minecraft:powder_snow_bucket",
"minecraft:glow_berries",
"minecraft:potato",
"minecraft:sweet_berries",
"minecraft:redstone"
}


-- The 'for (let id of itemIds)' loop is translated to 'for _, id in ipairs(itemIds) do'

for _, id in ipairs(itemIds) do
-- Assuming 'renderAsBlock.put' is a method, using the preferred colon syntax for consistency
renderAsBlock:put(id, false)
if id ~= "bamboo" then
translateItem:put(id, true)
end
end

for _, id in ipairs(tags) do
if(I:isIn(context.item, Tags:getVanillaTag(id))) then
renderAsBlock:put(I:getName(context.item), false)
end
end


itemSwingSpeed:put('minecraft:trident', 12)
itemSwingSpeed:put('minecraft:iron_spear', 15)
itemSwingSpeed:put('minecraft:copper_spear', 15)
itemSwingSpeed:put('minecraft:diamond_spear', 15)
itemSwingSpeed:put('minecraft:wooden_spear', 15)
itemSwingSpeed:put('minecraft:stone_spear', 15)
itemSwingSpeed:put('minecraft:golden_spear', 15)
itemSwingSpeed:put('minecraft:netherite_spear', 15)
itemSwingSpeed:put('minecraft:mace', 12)


if I:isIn(context.item, Tags:getVanillaTag('shovels')) then
itemSwingSpeed:put(I:getName(context.item), 14)
end

--I:setChestOpen(M:clamp(fall / 6, 0, 1))
--I:setShulkerOpen(M:clamp(fall / 6, 0, 1))


--Cyber, Sapling and Axolotl were here :3

local l = context.bl and 1 or -1

global.foodCount = 0.0;
global.foodCountO = 0.0;

local easedFoodCounter = Easings:easeInQuart(context.mainHand and foodCount or foodCountO)

-- Buckets
if (
I:isOf(context.item, Items:get("minecraft:bucket")) or
I:isOf(context.item, Items:get("minecraft:axolotl_bucket")) or
I:isOf(context.item, Items:get("minecraft:powder_snow_bucket")) or
I:isOf(context.item, Items:get("minecraft:pufferfish_bucket")) or
I:isOf(context.item, Items:get("minecraft:tadpole_bucket")) or
I:isOf(context.item, Items:get("minecraft:salmon_bucket")) or
I:isOf(context.item, Items:get("minecraft:cod_bucket")) or
I:isOf(context.item, Items:get("minecraft:tropical_fish_bucket")) or
I:isOf(context.item, Items:get("minecraft:water_bucket")) or
I:isOf(context.item, Items:get("minecraft:lava_bucket"))
) then
M:moveY(mat, 0.025)
M:moveX(mat, -0 * l)
M:moveZ(mat, -0.1)
M:rotateY(mat, 180)
M:rotateX(mat, -82.5)
M:rotateZ(mat, -20 * l)
end

-- Milk Bucket
if I:isOf(context.item, Items:get("minecraft:milk_bucket")) then
M:moveY(mat, 0.025)
M:moveX(mat, -0 * l)
M:moveZ(mat, -0.1)
M:rotateY(mat, 180)
M:rotateX(mat, -82.5)
M:rotateZ(mat, -20 * l)
M:rotateX(mat, -0 * easedFoodCounter)
M:rotateZ(mat, 30 * l * easedFoodCounter)
M:rotateY(mat, 0 * l * easedFoodCounter)
M:moveX(mat, 0 * l * easedFoodCounter)
M:moveY(mat, 0.1 * easedFoodCounter)
M:moveZ(mat, 0.02 * easedFoodCounter)
end

-- Lava Bucket
if I:isOf(context.item, Items:get("minecraft:lava_bucket")) then
particleManager:addParticle(
context.particles,
false,
-0.05 * l,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
2,
Texture:of("minecraft", "textures/particle/orange_glow.png"),
"ITEM",
context.hand,
"SPAWN",
"ADDITIVE",
0,
150 + (20 * M:sin(P:getAge(context.player) * 0.2))
)
end

-- Frog Buckets (Holld my Frog mod)
if (
I:isOf(context.item, Items:get("bucket_of_frog:frog_bucket_cold")) or
I:isOf(context.item, Items:get("bucket_of_frog:frog_bucket_warm")) or
I:isOf(context.item, Items:get("bucket_of_frog:frog_bucket_temperate"))
) then
M:moveY(mat, 0.025)
M:moveX(mat, -0 * l)
M:moveZ(mat, -0.1)
M:rotateY(mat, 180)
M:rotateX(mat, -82.5)
M:rotateZ(mat, -20 * l)
end

if I:getUseAction(context.item) == "trident" then
--M:moveZ(mat, -0.1 * Easings:easeOutBack(M:clamp(tridentM * 1.5, 0, 1)))

M:rotateZ(mat, 170 * l * Easings:easeOutBack(M:clamp(context.mainHand and tridentM or tridentMO * 1.5, 0, 1)))
M:moveZ(mat, -0.1)
M:rotateY(mat, 40 * l)
end

if I:getUseAction(context.item) == "spear" then
    M:moveZ(mat, -0.1)
    M:rotateY(mat, 10 * l)
end

global.riptideCounter = 0;
global.riptideCounterO = 0;

if I:getUseAction(context.item) == "trident" then
M:rotateX(mat, -90 * Easings:easeOutBack(M:sin(context.mainHand and riptideCounter or riptideCounterO * 3.14)))
M:rotateZ(mat, -45 * l * Easings:easeOutBack(M:sin(context.mainHand and riptideCounter or riptideCounterO * 3.14)))
end

-- 5.1.2: restored the 26.2 block grip (applyBlockRotation), upscale lowered 1.1 -> 1.0
if I:isIn(context.item, Tags:getVanillaTag("hanging_signs"))
or I:isIn(context.item, Tags:getVanillaTag("doors")) 
or I:isIn(context.item, Tags:getVanillaTag("skulls"))
or I:isIn(context.item, Tags:getVanillaTag("signs")) then
    applyBlockRotation:put(I:getName(context.item), false)
end

if I:isBlock(context.item) and applyBlockRotation:getOrDefault(I:getName(context.item), true) and renderAsBlock:getOrDefault(I:getName(context.item), true) and not
I:isOf(context.item, Items:get("minecraft:pink_petals")) and not
I:isOf(context.item, Items:get("minecraft:leaf_litter")) and not
I:isOf(context.item, Items:get("minecraft:wildflowers")) and not
I:isOf(context.item, Items:get("minecraft:redstone")) and not
I:isOf(context.item, Items:get("minecraft:bell")) then
M:moveX(mat, -0.025 * l) -- 5.1.2: pulled inward 0.025 (x-axis, towards body)
M:moveZ(mat, -0.075) -- 5.1.2: moved forward 0.025 (towards -z) from -0.05
if not I:isLantern(context.item) then
M:moveY(mat, -0.065625) -- 5.1.2: raised ~1.35 texture px (0.084375) from -0.15
M:rotateZ(mat, 6 * l)
M:rotateX(mat, -8)
end
M:rotateY(mat, 25 * l)
M:scale(mat, 0.9375, 0.9375, 0.9375)
end


local easedBow = Easings:easeInOutBack(bowCount)
local easedBowO = Easings:easeInOutBack(bowCountO)
local easedBowSec = Easings:easeOutBack(bowCountSec)
local easedBowSecO = Easings:easeOutBack(bowCountSecO)
local bc = context.mainHand and easedBowSec or easedBowSecO
local b = context.mainHand and easedBow or easedBowO


if bc < 0.1 then
usingItem:put("minecraft:bow", false)
else
usingItem:put("minecraft:bow", true)
end

useDuration:put("minecraft:bow", Easings:cubicEase(bc) * 20)

local easedCrossBowM = Easings:easeOutBack(crossBowM)
local easedCrossBowSecM = Easings:easeOutBack(crossBowSecM)
local easedCrossBowO = Easings:easeOutBack(crossBowO)
local easedCrossBowSecO = Easings:easeOutBack(crossBowSecO)


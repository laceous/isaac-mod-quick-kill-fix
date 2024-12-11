local mod = RegisterMod('Quick Kill Fix', 1)
local game = Game()

-- filtered to ENTITY_THE_LAMB/ENTITY_DELIRIUM/ENTITY_ROTGUT/ENTITY_MOTHER/ENTITY_DOGMA
function mod:onNpcUpdate(npc)
  local quickKillEnabled
  if REPENTOGON then
    quickKillEnabled = game:GetDebugFlags() & DebugFlag.QUICK_KILL == DebugFlag.QUICK_KILL
  else
    Isaac.ExecuteCommand('debug 10') -- toggle
    quickKillEnabled = Isaac.ExecuteCommand('debug 10') == 'Enabled debug flag.'
  end
  
  if quickKillEnabled then
    if npc.Type == EntityType.ENTITY_THE_LAMB and npc.Variant == 10 then -- 0=lamb, 10=body
      if npc.HitPoints <= 0.0 and npc.State == NpcState.STATE_SPECIAL and npc:GetSprite():GetAnimation() == 'Body' and npc:GetEntityFlags() & EntityFlag.FLAG_BOSSDEATH_TRIGGERED == EntityFlag.FLAG_BOSSDEATH_TRIGGERED then
        npc.State = NpcState.STATE_DEATH -- stop the poof animation from constantly playing
      end
    elseif npc.Type == EntityType.ENTITY_DELIRIUM and npc.Variant == 0 then
      -- delirium gets stuck in a loop and never finishes dying
      if npc.HitPoints <= 1.0 and npc.State == NpcState.STATE_APPEAR and npc:GetSprite():GetAnimation() == 'Idle' then
        npc.State = NpcState.STATE_UNIQUE_DEATH -- unique death allows us to play the scream animation
        npc:GetSprite():Play('Scream', true)
      end
    elseif npc.Type == EntityType.ENTITY_ROTGUT and npc.Variant == 0 then -- 0=rotgut, 1=maggot, 2=heart
      if npc.HitPoints < npc.MaxHitPoints and npc.State == NpcState.STATE_SPECIAL and (npc:GetSprite():GetAnimation() == 'Transition' or npc:GetSprite():GetAnimation() == 'TransitionLoop') then
        npc.HitPoints = npc.MaxHitPoints -- allow TransitionLoop to play so you can proceed to the next phase
        npc:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
      end
    elseif npc.Type == EntityType.ENTITY_MOTHER and npc.Variant == 0 then -- 0=mother, 10=mother2 / subtypes=0,1,2,3
      if npc.HitPoints < npc.MaxHitPoints then
        for _, v in ipairs(Isaac.FindByType(npc.Type, npc.Variant, -1, true, false)) do -- protect all subtypes
          if v:ToNPC().State == NpcState.STATE_SPECIAL and (v:GetSprite():GetAnimation() == 'Transition' or v:GetEntityFlags() & EntityFlag.FLAG_BOSSDEATH_TRIGGERED == EntityFlag.FLAG_BOSSDEATH_TRIGGERED) then
            npc.HitPoints = npc.MaxHitPoints -- don't get softlocked before mother2 spawns
            break
          end
        end
      end
    elseif npc.Type == EntityType.ENTITY_DOGMA and npc.Variant == 0 then -- 0=regular, 1=tv, 2=angel
      if npc.HitPoints < npc.MaxHitPoints then
        npc.HitPoints = npc.MaxHitPoints -- don't get softlocked before tv and angel spawn
      end
    end
  end
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.onNpcUpdate, EntityType.ENTITY_THE_LAMB)
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.onNpcUpdate, EntityType.ENTITY_DELIRIUM)
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.onNpcUpdate, EntityType.ENTITY_ROTGUT)
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.onNpcUpdate, EntityType.ENTITY_MOTHER)
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.onNpcUpdate, EntityType.ENTITY_DOGMA)
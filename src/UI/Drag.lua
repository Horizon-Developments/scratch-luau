local UserInputService = game:GetService("UserInputService")

local Drag = {}

-- Follows one pointer (mouse button 1 or one touch) until it lifts. Positions are screen pixels.
function Drag.track(input, onMove, onEnd)
  local touch = input.UserInputType == Enum.UserInputType.Touch
  local moved, ended
  moved = UserInputService.InputChanged:Connect(function(i)
    if i == input or (not touch and i.UserInputType == Enum.UserInputType.MouseMovement) then
      onMove(Vector2.new(i.Position.X, i.Position.Y))
    end
  end)
  ended = UserInputService.InputEnded:Connect(function(i)
    if i == input or (not touch and i.UserInputType == input.UserInputType) then
      moved:Disconnect()
      ended:Disconnect()
      if onEnd then onEnd(Vector2.new(i.Position.X, i.Position.Y)) end
    end
  end)
end

return Drag

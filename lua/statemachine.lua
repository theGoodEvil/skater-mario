local machine = {}
machine.__index = machine


local function call_handler(handler, params)
  if handler then
    return handler(unpack(params))
  end
end

local function create_transition(name)
  return function(self, ...)
    local can, to = self:can(name)

    if can then
      local from = self.current
      local params = { self.self, name, from, to, ... }

      if call_handler(self.will.apply[name], params) == false
      or call_handler(self.will.leave[from], params) == false
      or call_handler(self.will.enter[to], params) == false then
        return false
      end

      self.current = to

      call_handler(self.did.enter[to], params)
      call_handler(self.did.leave[from], params)
      call_handler(self.did.apply[name], params)

      return true
    end

    return false
  end
end

local function add_to_map(map, event)
  if type(event.from) == 'string' then
    map[event.from] = event.to
  else
    for _, from in ipairs(event.from) do
      map[from] = event.to
    end
  end
end

function machine.create(options)
  assert(options.events)

  local fsm = {
    will = {
      enter = {},
      leave = {},
      apply = {}
    },
    did = {
      enter = {},
      leave = {},
      apply = {}
    }
  }
  setmetatable(fsm, machine)

  fsm.current = options.initial or 'none'
  fsm.self = options.self or fsm
  fsm.events = {}

  for _, event in ipairs(options.events) do
    fsm:add_event(event)
  end

  return fsm
end

function machine:add_event(event)
  local name = event.name
  self[name] = self[name] or create_transition(name)
  self.events[name] = self.events[name] or { map = {} }
  add_to_map(self.events[name].map, event)
end

function machine:is(state)
  return self.current == state
end

function machine:can(e)
  local event = self.events[e]
  local to = event and event.map[self.current]
  return to ~= nil, to
end

function machine:cannot(e)
  return not self:can(e)
end

return machine

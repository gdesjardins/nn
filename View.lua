local View, parent = torch.class('nn.View', 'nn.Module')

function View:__init(...)
   parent.__init(self)
   self.size = ...
   if select('#', ...) > 1 or type(self.size) == "number" then
      self.size = torch.LongStorage({...})
   end
   assert(torch.typename(self.size)=="torch.LongStorage", "expecting a LongStorage")
   self.numElements = 1
   for i = 1,#self.size do
      self.numElements = self.numElements * self.size[i]
   end

   self.output = nil
   self.gradInput = nil
   self.numInputDims = nil
end

function View:setNumInputDims(numInputDims)
   self.numInputDims = numInputDims
   return self
end

local function isMinibatch(input, numInputDims, numElements)
   if numInputDims then
      return input:dim() == numInputDims+1
   else
      return input:dim() > 1 and
             input:nElement()/input:size(1) == numElements
   end
end

function View:updateOutput(input)
   if isMinibatch(input, self.numInputDims, self.numElements) then
      self.output = input:view(input:size(1), unpack(self.size:totable()))
   else
      self.output = input:view(self.size)
   end
   return self.output
end

function View:updateGradInput(input, gradOutput)
   self.gradInput = gradOutput:view(input:size())
   return self.gradInput
end

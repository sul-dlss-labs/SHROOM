# frozen_string_literal: true

module RorEmbeddings
  # Embedding model for text
  # See https://github.com/ankane/neighbor/blob/master/examples/sparse/example.rb
  class Model
    def initialize(model_id: 'opensearch-project/opensearch-neural-sparse-encoding-v1')
      @model = Transformers::AutoModelForMaskedLM.from_pretrained(model_id)
      @tokenizer = Transformers::AutoTokenizer.from_pretrained(model_id)
      @special_token_ids = @tokenizer.special_tokens_map.map { |_, token| @tokenizer.vocab[token] }
    end

    # @param input [Array<String>] the input text
    def embed(input)
      feature = @tokenizer.call(input, padding: true, truncation: true, return_tensors: 'pt',
                                       return_token_type_ids: false)
      output = @model.call(**feature)[0]
      values = Torch.max(output * feature[:attention_mask].unsqueeze(-1), dim: 1)[0]
      values = Torch.log(1 + Torch.relu(values))
      values[0.., @special_token_ids] = 0
      values.to_a
    end

    # @param input [String] the input text
    def embed_single(input)
      embed(Array(input))[0]
    end
  end
end

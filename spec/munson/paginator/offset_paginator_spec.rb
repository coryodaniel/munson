require 'spec_helper'

describe Munson::Paginator::OffsetPaginator do
  describe '#limit' do
    it 'sets the offset' do
      pager = Munson::Paginator::OffsetPaginator.new
      pager.set(offset: 3)

      page_params = pager.to_params[:page]
      expect(page_params).to include({offset: 3})
    end

    context 'when using the default limit' do
      it 'returns the default limit' do
        opts = { default: 10 }
        pager = Munson::Paginator::OffsetPaginator.new(opts)

        params = pager.to_params
        expect(params).to include({page: {limit: 10}})
      end
    end

    context 'when over the max limit' do
      it 'returns the max limit' do
        opts = { max: 100 }
        pager = Munson::Paginator::OffsetPaginator.new(opts)
        pager.set(limit: 1000)

        params = pager.to_params
        expect(params).to include({page: {limit: 100}})
      end
    end
  end

  context 'when no options are set' do
    context 'when the limit is not specified' do
      it 'defaults to 10' do
        pager = Munson::Paginator::OffsetPaginator.new
        params = pager.to_params
        expect(params).to include({page: {limit: 10}})
      end
    end
  end
end

require 'spec_helper'

describe Munson::Paginator::PagedPaginator do
  describe '#set' do
    it 'sets the number' do
      pager = Munson::Paginator::PagedPaginator.new
      pager.set(number: 3)

      page_params = pager.to_params[:page]
      expect(page_params).to include({number: 3})
    end

    context 'when using the default size' do
      it 'returns the default size' do
        opts = { default: 10 }
        pager = Munson::Paginator::PagedPaginator.new(opts)

        params = pager.to_params
        expect(params).to include({page: {size: 10}})
      end
    end

    context 'when over the max size' do
      it 'returns the max size' do
        opts = { max: 100 }
        pager = Munson::Paginator::PagedPaginator.new(opts)
        pager.set(size: 1000)

        params = pager.to_params
        expect(params).to include({page: {size: 100}})
      end
    end
  end

  context 'when no options are set' do
    context 'when the size is not specified' do
      it 'defaults to 10' do
        pager = Munson::Paginator::PagedPaginator.new
        params = pager.to_params
        expect(params).to include({page: {size: 10}})
      end
    end
  end
end

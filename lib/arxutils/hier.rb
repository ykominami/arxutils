# -*- coding: utf-8 -*-

module Arxutils
  class HierOp
    def initialize( hier_symbol , base_klass , hier_klass , current_klass )
      @hier_symbol = hier_symbol
      @base_klass = base_klass
      @hier_klass = hier_klass
      @current_klass = current_klass
    end
    
    def delete( hier )
      # 子として探す
      row_item  = @base_klass.find_by( { @hier_symbol => hier } )
      delete_at( row_item.id )
    end

    def move( src_hier , dest_parent_hier )
      # dest_parent_hierがsrc_hierの子であれば(=src_hierがdest_parent_hierの先頭からの部分文字列である)何もせずエラーを返す
      escaped = Regexp.escape( src_hier )
      src_re = Regexp.new( %Q!^#{escaped}! )
      ret = ( src_re =~ dest_parent_hier )
      # 自身の子への移動はエラーとする
      if ret
        return false
      end
      
      src_row_item = @base_klass.where( name: src_hier )
      src_num = src_row_item.id
      # srcが子である(tblでは項目を一意に指定できる)のtblでの項目を得る
      src_row = @hire_klass.find_by( child_id: src_num )
      
      dest_parent_row_item = @base_klass.find_by( name: dest_parent_hier )
      unless dest_parent_row_item
        dest_parent_num = register( dest_parent_hier )
      else
        dest_parent_num = dest_parent_row_item.id
      end
      dest_parent_level = get_level_by_child( dest_parent_num )
      
      # srcの親をdest_parentにする
      src_row.parent_id = dest_parent_num

      # destに移動後のsrcの子のレベルを調整する
      level_adjust( src_row , dest_parent_level )
      # destに移動後のsrcのhierを再設定
      set_hier( src_row_item ,  make_hier( dest_parent_row_item.name , get_name( src_row_item ) ) )
      # destに移動後のsrcの子のhierを調整する
      hier_adjust( src_row_item )

      true
    end

    def register_parent( hier_ary , child_num , level )
      hier_ary.pop
      parent_hier_ary = hier_ary
      parent_hier = parent_hier_ary.join('/')
      parent_num = register( parent_hier )
      hs = { parent_id: parent_num , child_id: child_num , level: level }
      @hier_klass.create( hs )
    end
    
    def register( hier )
      hier_ary = hier.split('/')
      level = get_level_by_array( hier_ary )

      # もしhier_aryがnilだけを1個持つ配列、または空文字列だけを1個もつ配列であれば、hier_nameは空文字列になる

      item_row = @current_klass.find_by( name: hier )
      unless item_row
        new_category = @base_klass.create( name: hier )
        new_num = new_category.id
        if level == 0
          unless @hier_klass.find_by( child_id: new_num )
            hs = {parent_id: new_num , child_id: new_num , level: level}
            @hier_klass.create( hs )
          end
        else
          register_parent( hier_ary , new_num, level )
        end
      else
        new_num = item_row.org_id
        if level == 0
          unless @hier_klass.find_by( child_id: new_num )
            hs = {parent_id: new_num , child_id: new_num , level: level}
            @hier_klass.create( hs )
          end
        else
          unless @hier_klass.find_by( child_id: new_num )
            register_parent( hier_ary , new_num, level )
          end
        end
      end
      new_num
    end
    
    private
    
    def delete_at( num )
      # 子として探す
      row = @hier_klass.find_by( child_id: num )
      level = row.level
      parent_id = row.parent_id
      row_item = @base_klass.find( num )
      
      parent_item_row = @base_klass.find( parent_id )
      parent_hier  = parent_item_row.name

      # 属する子を探す
      child_rows = @hier_klass.where( parent_id: num )
      # 属する子の階層レベルを調整する(削除するのでlevel - 1になる)
      child_rows.map{ |x| level_adjust( x , level - 1 ) }
      # 属する子の親を、親の親にする
      child_rows.map{ |x|
        x.parent_id = parent_id
      }
      # 属する子のhierを調整する
      child_rows.map{ |x|
        child_item_row = @base_klass.find( x.child_id )
        name = get_name( child_item_row )
        child_item_row.name = make_hier( parent_hier , name )
        hier_adjust( child_item_row )
      }
    end

    def get_level_by_array( hier_ary )
      level = hier_ary.size - 1
      level = 0 if level < 0
      level
    end

    def get_name( items_row )
      name = ""
      if items_row
        name = items_row.name.split('/').pop
      end
      name
    end

    def hier_adjust( item_row )
      parent_hier = item_row.name
      parent_num = item_row.id

      tbl_rows = @hier_klass.where( parent_id: parent_num )
      if tbl_rows.size > 0
        tbl_rows.map{|x|
          child_num = x.child_id
          item_row = @base_klass.find( child_num )
          item_row.name =  make_hier( parent_hier , get_name( item_row ) )
          hier_adjust( item_row )
        }
      end
    end
    
    # 指定項目と、その子のlevelを調整
    def level_adjust( row , parent_level )
      row.level = parent_level + 1
      child_rows = @hier_klass.where( paernt_id: row.id )
      if child_rows.size > 0
        child_rows.map{ |x| level_adjust( x , row.level ) }
      end
    end  

    def get_level_by_child( num )
      @hier_klass.find_by( child_id: num ).level
    end

    def make_hier( parent_hier , name )
      [ parent_hier , name ].join('/')
    end
  end
end

package com.rnsimiselector.adapter.holder;

import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.rnsimiselector.R;
import com.rnsimiselector.config.SelectMimeType;
import com.rnsimiselector.config.SelectorProviders;
import com.rnsimiselector.permissions.PermissionChecker;
import com.rnsimiselector.style.SelectMainStyle;
import com.rnsimiselector.utils.StyleUtils;

/**
 * @author：
 * @date：2021/11/20 3:54 下午
 * @describe：CameraViewHolder
 */
public class AddSelectViewHolder extends BaseRecyclerMediaHolder {

    public AddSelectViewHolder(View itemView) {
        super(itemView);
        ImageView tvAddSelect = itemView.findViewById(R.id.tvAddSelect);
        selectorConfig = SelectorProviders.getInstance().getSelectorConfig();
        SelectMainStyle adapterStyle = selectorConfig.selectorStyle.getSelectMainStyle();
        int background = adapterStyle.getAdapterCameraBackgroundColor();
        if (StyleUtils.checkStyleValidity(background)) {
            tvAddSelect.setBackgroundColor(background);
        }
    }

}

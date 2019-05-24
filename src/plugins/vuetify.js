import "material-design-icons-iconfont/dist/material-design-icons.css";
import Vue from "vue";
import Vuetify from "vuetify/lib";
import "vuetify/src/stylus/app.styl";

import colors from "vuetify/es5/util/colors";

Vue.use(Vuetify, {
  iconfont: "md",
  theme: {
      primary: colors.green.base,
      secondary: colors.green.darken1,
      accent: colors.red.base
  }
});

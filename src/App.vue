<template>
  <v-app>
    <!-- <Toolbar></Toolbar> -->
    <v-content>
      <List/>
    </v-content>
  </v-app>
</template>

<script>
import List from './components/List';
import Toolbar from './components/Toolbar';

export default {
  name: 'App',
  components: {
    List,
    Toolbar
  },
  data () {
    return {
      //
    }
  }
}
</script>

<template>
    <div id="app">
  <v-app id="inspire">
    <v-footer
      color="primary lighten-1"
      padless
    >
      <v-row
        justify="center"
        no-gutters
      >
        <v-btn
          v-for="link in links"
          :key="link"
          color="white"
          text
          rounded
          class="my-2"
        >
          {{ link }}
        </v-btn>
        <v-col
          class="primary lighten-2 py-4 text-center white--text"
          cols="12"
        >
          {{ new Date().getFullYear() }} — <strong>Blockchain DAPP CrowdFunding Project </strong>
        </v-col>
      </v-row>
    </v-footer>
  </v-app>
</div>
</template>

<script>
  export default {
    name: 'footer',

    data: () => ({
        links: [
      'Home',
      'About Us',
      'Team',
      'Services',
      'Blog',
      'Contact Us',
    ],
      
    }),
  }
</script>
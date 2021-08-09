<template>
<div id="app">
  <v-app id="inspire">
    <v-carousel
      cycle
      height="400"
      hide-delimiter-background
      show-arrows-on-hover
    >
      <v-carousel-item
        v-for="(slide, i) in slides"
        :key="i"
      >
        <v-sheet
          :color="colors[i]"
          height="100%"
        >
          <v-row
            class="fill-height"
            align="center"
            justify="center"
          >
            <br>
            <br>
            <br>
            <br>
            <h1 class="display-2 font-weight-bold mb-3">
            Amazing Crowdfunding
            </h1>
            <div class="display-2 font-weight-bold mb-3">
                {{ slide }} 
            </div>
          </v-row>
        </v-sheet>
      </v-carousel-item>
    </v-carousel>

    <v-container>
    <v-row class="text-center">
      <v-col cols="12">
      </v-col>

      <v-col class="mb-4">
        <br>
        <h1 class="display-6 font-weight-bold mb-3">
          Problem Statement
        </h1>
        <p class="subheading font-weight-regular">
         {{problem_text}}
        </p>

        <br>
        <h1 class="display-6 font-weight-bold mb-3">
          Our Solution
        </h1>
        <p class="subheading font-weight-regular">
         {{solution_text}}
        </p>

        <br>
        <h1 class="display-6 font-weight-bold mb-3">
          Use cases
        </h1>
        <p class="subheading font-weight-regular">
         {{usecases_text}}
        </p>
        <p class="subheading font-weight-regular"><b>Indie games</b>
         {{usecases_text1}}
        </p>
        <p class="subheading font-weight-regular"><b>Charity</b>
         {{usecases_text2}}
        </p>
      </v-col>
      <br>
      <v-col
        class="mb-5"
        cols="12"
      >
        <h2 class="headline font-weight-bold mb-3">
          More about our project 
        </h2>
        <br>
        <v-row justify="center">
          <a
            v-for="(link, i) in importantLinks"
            :key="i"
            :href="link.href"
            class="subheading mx-3"
            target="_blank"
          >
            {{ link.text }}
          </a>
        </v-row>
      </v-col>
    </v-row>
  </v-container>
  </v-app>
</div>
  
</template>

<script>
  export default {
    name: 'top',

    data: () => ({
        
      colors: [
        'indigo',
        'warning',
        'pink darken-2',
        'red lighten-1',
        'deep-purple accent-4',
      ],

      slides: [
        'Raise Money',
        'Decentralized',
        'No Third Party',
        'Blockchain Technology',
        'Convenient',
      ],

      problem_text:'Currently, there are several disadvantages with typical crowdfunding platforms:Most crowdfunding platforms take a cut from the funds being raised in order to sustain the platform, which means less money for the project starters. There is no enforcing of responsibility for fundraisers, which leads to the prevalence of scams and undelivered projects, where project starters misuse funds donated.Having a fundraising platform acting as a third-party intermediate introduce a point of failure, i.e. risk of the platform shutting down halfway through the funding process'
,
      solution_text:'This project aims to solve this problem by developing a simple Ethereum-based crowdfunding decentralized application (DApp) for crowdfunding projects. The DApp will be an application built on a decentralized peer-to-peer network that combines a smart contact and a Vue frontend user interface. It is accessible, transparent, decentralized, deterministic, turing complete, isolated and distributed. By setting up a decentralized platform, we can create a trustless platform, and as a result, everyone will only have to pay for gas. ',
      usecases_text:'Both groups/organisations and individuals are able to use this platform. Usually, if a group/organisation is starting a crowdfunding project, a deliverable is expected, hence the need for releasing only a portion of the funds if the funders are satisfied. These deliverables can range from game development updates to service or products given by charity organisations to needy individuals.On the other hand, individuals starting a crowdfunding project tend not to promise a deliverable in exchange for donations. Such individuals could be students looking for funds for medical treatment, or someone in poverty stricken areas that need money to provide for their family. Below are some specific use cases',
      usecases_text1:'Developers/game enthusiasts may need funding to gather a suitable team for developing their game. Crowdfunding allows them to garner both an audience and the amount of money they need to do so. Having a secure way of collecting funds provides funders with a sense of security and confidence that their money goes directly to supporting the game. Likewise, developers receive ample funding and with the secure transactions, can achieve a level of professionalism comparable to mainstream game companies. They are also able to avoid platform fees which most platforms implement, in order to keep the organisation up.',
      usecases_text2:'Individuals may reach out to the public for donations to help with personal financial issues, but there is a common worry amongst donators, regarding whether or not their money actually goes into helping the cause they donated to. With this DApp, donators will be donating directly to the needy party, and have access to information about transactions made with their donation. Likewise, receivers of the donation do not have to worry about a third party possibly siphoning money for their own profit.',
      importantLinks: [
        {
          text: 'Documentation',
          href: 'https://vuetifyjs.com',
        },
        {
          text: 'Functions',
          href: 'https://community.vuetifyjs.com',
        },
        {
          text: 'SmartContract',
          href: 'https://madewithvuejs.com/vuetify',
        },
        {
          text: 'Past Successful Projects',
          href: 'https://twitter.com/vuetifyjs',
        },
        {
          text: 'Teams',
          href: 'https://medium.com/vuetify',
        },
      ],
      
    }),
  }
</script>

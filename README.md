# EcoFlora : Home Garden Biodiversity App

## Overview

This project is a mobile app to educate and promote biodiversity in home gardens. The app utilizes state-of-the-art plant identification and biodiversity informatiion APIs to help users identify plants in their gardens, providing detailed information about each plant's native roots and daily care and helps you find native plants in your region.

## Features

- **Plant Identification**: Upload images of plants to identify them using the PlantNet API.
- **Garden Index**: Store information about your plants.
- **Native Plant Finder**: Explore a comprehensive database of native plants based on region.
- **Saved Plants**: save the native plants you are interested in.
- **Care Log**: Receive automatic daily reminders to water and additional todos related to plant care.
- **Contribute**: Find biodiversity and conservation groups near uypu to join and donate.
## Getting Started

### Prerequisites

- Flutter SDK
- Dart 3
- A valid API key for the PlantNet API
- A valid API key for the Trefle API
- valid google client ids
- valid supabase access url and anon key

### Installation

1. **Clone the mobile_app branch of the repository**:
   ```bash
   git clone --branch mobile_app https://github.com/yourusername/home-garden-biodiversity.git
   cd ecoflora
   ```
2. **Install dependencies:**:
   ```bash
   flutter pub get
   ```
3. **Add and configure .env**:<br>
   Use .env.example as template
4. **Run app**:
   ```bash
   flutter run
   ```

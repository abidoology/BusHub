# Chapter 1: Introduction
## 1.1 Background
Dhaka, the capital city of Bangladesh, is one of the most densely populated and rapidly growing cities in the world. The public transportation system is heavily reliant on buses, which serve as the primary mode of transport for a vast majority of the population. However, this system is plagued by a significant challenge: a lack of accessible, organized, and reliable information regarding bus routes, stops, and corresponding fares. Daily commuters, as well as occasional visitors, often find themselves in a state of confusion, relying on word-of-mouth or outdated, inaccurate sources. This information gap leads to inefficient travel, wasted time, and increased frustration for millions of people navigating the city daily.
## 1.2 Project Overview
The "Dhaka Bus Route & Fare Finder" is a mobile application designed to address this critical issue. It serves as a centralized platform for users to search for bus routes between two points in Dhaka, view the complete route with all stops, and instantly calculate the total fare. The app is built with a user-centric design, featuring a simple and intuitive interface for general users and a robust admin panel for managing the underlying data. By leveraging modern technology, the app aims to make public bus travel in Dhaka more transparent, efficient, and accessible.
## 1.3 Problem Statement
The primary problem this project seeks to solve is the absence of a structured and reliable information system for Dhaka's bus routes and fares. Currently, no single, up-to-date source provides comprehensive details for all buses operating in the city. This leads to several issues:
- **Inefficient Travel:** Passengers waste time waiting for unknown buses or taking incorrect routes.
- **Financial Uncertainty:** Passengers often cannot determine the correct fare from their origin to their destination, leading to overcharging or disputes.
- **Inaccessibility for Visitors:** Tourists and newcomers find it extremely difficult to use the public bus system.
- **Administrative Challenges:** The lack of a centralized database makes it difficult for authorities to manage and update route information effectively.
## 1.4 Objectives
The main objectives of this project are:
1.	To develop a cross-platform mobile application for both Android and iOS that allows users to search for buses in Dhaka.
2.	To create a database of bus routes, stops, and fares for the city.
3.	To implement an intuitive user interface for searching buses between a source and a destination.
4.	To display the complete route with stops and accurate fare calculation.
5.	To provide an interactive map visualization for routes using OpenStreetMap (OSM).
6.	To develop a secure administrative panel for adding, editing, and deleting bus and location data.
7.	To ensure the application is robust, reliable, and easy to use for people from all walks of life.
## 1.5 Scope
The scope of this project is primarily focused on the city of Dhaka. While it can serve as a foundational model for other cities, the initial data and features are tailored to the Dhaka bus network. The key functionalities within the scope include:
- User Authentication for admin.
- Searching buses between two locations.
- Displaying bus routes, stop lists, and fare breakdowns.
- Visualizing routes on a map.
- Admin management of buses (CRUD operations) and locations.
- Admin login functionality.
## 1.6 Motivation
The motivation behind this project is deeply rooted in the day-to-day challenges faced by the people of Dhaka. The constant struggle to find a correct bus, the anxiety of an unknown fare, and the overall inefficiency of the system are everyday realities. This project aims to create a digital solution that brings ease and confidence to the lives of millions of commuters. It is an attempt to harness the power of modern technology to solve a pervasive, real-world problem and contribute to the digital transformation of public services in Bangladesh.
## 1.7 Significance
This project holds significant importance for several stakeholders:
- **Commuters:** It provides them with a reliable, on-demand source of information, saving time and money and reducing travel-related stress.
- **Administration:** It offers a digital framework for managing and disseminating public transport data, leading to better planning and service quality.
- **Local Government:** It supports the "Smart Bangladesh" vision by digitizing a key public service.
- **Researchers and Developers:** It serves as a case study for developing similar applications for other cities and can be a foundation for future research in intelligent transportation systems.
## 1.8 Expected Outcome
The expected outcome of this project is a fully functional and user-friendly mobile application for Dhaka's bus system. It will provide a reliable, accurate, and accessible platform for users to find bus routes and fares. The successful implementation will demonstrate the viability of using open-source technologies like Flutter and OSM to solve complex real-world problems and set a precedent for similar projects in other urban centres.
## 1.9 Limitations
- **Data Dependency:** The accuracy and comprehensiveness of the application are heavily dependent on the administrative data input. Initial data must be manually entered.
- **Coverage:** The current scope is limited to the municipal area of Dhaka.
- **Real-time Updates:** The system does not currently support real-time bus tracking or dynamic route changes, which may affect accuracy if bus routes are updated in real life.
- **Internet Dependency:** The app requires an active internet connection to fetch data from Firebase and load map tiles.

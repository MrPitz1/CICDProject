# FRONTEND STAGE
FROM docker.io/node:23.7.0 AS frontend-build
WORKDIR /app
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY frontend/ ./
RUN npx ng build

# BACKEND STAGE
FROM docker.io/golang:1.23.4 AS backend-build
WORKDIR /app
COPY backend/go.mod backend/go.sum ./
RUN go mod download
COPY backend/ ./
COPY --from=frontend-build /app/dist/frontend/browser ./cmd/strichliste/frontendDist
RUN CGO_ENABLED=0 go build -o ./strichliste ./cmd/strichliste/main.go

# FINAL STAGE
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=backend-build /app/strichliste /strichliste
EXPOSE 8080
ENTRYPOINT ["/strichliste"]

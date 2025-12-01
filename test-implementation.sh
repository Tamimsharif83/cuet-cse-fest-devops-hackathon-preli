#!/bin/bash

# Test script to verify the complete implementation
# Run with: ./test-implementation.sh

set -e

echo "================================================"
echo "🧪 Testing E-Commerce DevOps Implementation"
echo "================================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "Testing: $test_name ... "
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAILED${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

echo "1. Testing Health Endpoints"
echo "----------------------------"
run_test "Gateway health" "curl -s http://localhost:5921/health | grep -q '\"ok\":true'"
run_test "Backend health via gateway" "curl -s http://localhost:5921/api/health | grep -q '\"ok\":true'"
echo ""

echo "2. Testing Product CRUD Operations"
echo "-----------------------------------"
# Create product
PRODUCT_ID=$(curl -s -X POST http://localhost:5921/api/products \
  -H 'Content-Type: application/json' \
  -d '{"name":"Test Item","price":29.99}' | grep -o '"_id":"[^"]*' | cut -d'"' -f4)

run_test "Create product" "[ ! -z '$PRODUCT_ID' ]"
run_test "Get all products" "curl -s http://localhost:5921/api/products | grep -q 'Test Item'"
echo ""

echo "3. Testing Security"
echo "-------------------"
run_test "Backend NOT directly accessible" "! curl -s -m 2 http://localhost:3847/api/products 2>&1"
run_test "MongoDB NOT directly accessible" "! nc -zv localhost 27017 2>&1"
echo ""

echo "4. Testing Docker Containers"
echo "-----------------------------"
run_test "Gateway container running" "docker ps | grep -q ecommerce-gateway-prod"
run_test "Backend container running" "docker ps | grep -q ecommerce-backend-prod"
run_test "MongoDB container running" "docker ps | grep -q ecommerce-mongo-prod"
run_test "Gateway is healthy" "docker ps | grep ecommerce-gateway-prod | grep -q 'healthy'"
run_test "Backend is healthy" "docker ps | grep ecommerce-backend-prod | grep -q 'healthy'"
run_test "MongoDB is healthy" "docker ps | grep ecommerce-mongo-prod | grep -q 'healthy'"
echo ""

echo "5. Testing Network Isolation"
echo "----------------------------"
run_test "Only Gateway port exposed" "docker ps | grep ecommerce-gateway-prod | grep -q '0.0.0.0:5921'"
run_test "Backend port NOT exposed" "! docker ps | grep ecommerce-backend-prod | grep -q '0.0.0.0:3847'"
run_test "MongoDB port NOT exposed" "! docker ps | grep ecommerce-mongo-prod | grep -q '0.0.0.0:27017'"
echo ""

echo "6. Testing Data Persistence"
echo "----------------------------"
PRODUCT_COUNT_BEFORE=$(curl -s http://localhost:5921/api/products | grep -o '_id' | wc -l)
run_test "Products exist before restart" "[ $PRODUCT_COUNT_BEFORE -gt 0 ]"

# Note: Actual restart test would be: docker compose restart && sleep 5 && check again
# Skipping actual restart to not interrupt running services
echo -e "${YELLOW}⚠ Full persistence test requires restart (skipped to keep services running)${NC}"
echo ""

echo "7. Testing Docker Volumes"
echo "-------------------------"
run_test "MongoDB data volume exists" "docker volume ls | grep -q ecommerce-mongo-data-prod"
run_test "MongoDB config volume exists" "docker volume ls | grep -q ecommerce-mongo-config-prod"
echo ""

echo "================================================"
echo "📊 Test Results"
echo "================================================"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed! Implementation is working correctly.${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed. Please review the implementation.${NC}"
    exit 1
fi

import { Query } from "@/types/Query";

export const getAllQueries = async () => {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_BACKEND_URL}/algebra/`,
    {
      method: "GET",
    }
  );

  return response.json();
};

export const getAllQueriesNames = async () => {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_BACKEND_URL}/algebra/names`,
    {
      method: "GET",
    }
  );

  return response.json();
};

export const getQueryById = async (queryId: number) => {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_BACKEND_URL}/algebra/${queryId}`,
    {
      method: "GET",
    }
  );

  return response.json();
};

export const addQuery = async (query: Query) => {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_BACKEND_URL}/algebra/`,
    {
      method: "POST",
      headers: {
        "Content-type": "application/json",
      },
      body: JSON.stringify(query),
    }
  );

  return response.json();
};

export const editQuery = async ({
  queryId,
  query,
}: {
  queryId: number;
  query: Query;
}) => {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_BACKEND_URL}/algebra/${queryId}`,
    {
      method: "PUT",
      headers: {
        "Content-type": "application/json",
      },
      body: JSON.stringify(query),
    }
  );

  return response.json();
};

export const deleteQuery = async (queryId: number) => {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_BACKEND_URL}/algebra/${queryId}`,
    {
      method: "DELETE",
    }
  );

  return response.json();
};

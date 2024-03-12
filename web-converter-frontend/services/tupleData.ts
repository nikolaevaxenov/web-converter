import { ConvertQuery, Query } from "@/types/Query";

export const getAllQueries = async () => {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_BACKEND_URL}/tuple/`,
    {
      method: "GET",
    }
  );

  return response.json();
};

export const getAllQueriesNames = async () => {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_BACKEND_URL}/tuple/names`,
    {
      method: "GET",
    }
  );

  return response.json();
};

export const getQueryById = async (queryId: number) => {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_BACKEND_URL}/tuple/${queryId}`,
    {
      method: "GET",
    }
  );

  return response.json();
};

export const addQuery = async (query: Query) => {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_BACKEND_URL}/tuple/`,
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
    `${process.env.NEXT_PUBLIC_BACKEND_URL}/tuple/${queryId}`,
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
    `${process.env.NEXT_PUBLIC_BACKEND_URL}/tuple/${queryId}`,
    {
      method: "DELETE",
    }
  );

  return response.json();
};

export const convertQuery = async (query: ConvertQuery) => {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_BACKEND_URL}/tuple/convert`,
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

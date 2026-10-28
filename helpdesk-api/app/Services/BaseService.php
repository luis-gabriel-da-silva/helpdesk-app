<?php

namespace App\Services;

use App\Repositories\Contracts\BaseRepositoryInterface;

abstract class BaseService
{
    protected BaseRepositoryInterface $repository;

    public function __construct(BaseRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    public function getAll(array $relations = [])
    {
        return $this->repository->all($relations);
    }

    public function getById(int $id, array $relations = [])
    {
        return $this->repository->find($id, $relations);
    }

    public function create(array $data)
    {
        return $this->repository->create($data);
    }

    public function update(int $id, array $data)
    {
        return $this->repository->update($id, $data);
    }

    public function delete(int $id)
    {
        return $this->repository->delete($id);
    }
}